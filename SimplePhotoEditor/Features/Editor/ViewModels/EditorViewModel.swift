import SwiftUI
import Combine
import PencilKit
import PhotosUI
import UIKit
import UniformTypeIdentifiers

@MainActor
final class EditorViewModel: ObservableObject {
    @Published var mode: EditorMode = .filters
    @Published var inputData: Data?
    @Published private(set) var previewImage: UIImage? = nil
    @Published private(set) var originalImage: UIImage? = nil

    @Published var selectedFilter: Filter? = nil
    @Published var rotationCount: Int = 0
    @Published var isFlippedHorizontally: Bool = false

    @Published var keyboardHeight: CGFloat = 0
    @Published var canvasSize: CGSize = .zero

    @Published var shareItem: ShareItem?

    // Формат экспорта
    @Published var exportFormat: ExportFormat = .png

    // PhotosPicker selection (UI управляет показом, VM — данными)
    @Published var libraryItem: PhotosPickerItem?

    private var pipeline: ImagePipeline
    private let exportService: ExportService

    let textVM = TextOverlayViewModel()

    private var cancellables = Set<AnyCancellable>()

    init(
        pipeline: ImagePipeline,
        exportService: ExportService
    ) {
        self.pipeline = pipeline
        self.exportService = exportService

        Publishers
            .CombineLatest($inputData, $selectedFilter)
            .debounce(for: .milliseconds(120), scheduler: RunLoop.main)
            .sink { [weak self] raw, fx in
                guard let self = self else { return }
                Task {
                    await self.updatePreview(raw: raw, filter: fx)
                }
            }
            .store(in: &cancellables)

        $inputData
            .sink { [weak self] data in
                guard let data = data else {
                    self?.originalImage = nil
                    return
                }
                self?.originalImage = UIImage(data: data)
            }
            .store(in: &cancellables)
    }

    func setMode(_ newMode: EditorMode) {
        guard newMode != mode else { return }
        applyMode(from: mode, to: newMode)
        mode = newMode
    }

    func toogleMode(_ target: EditorMode) {
        setMode(mode == target ? .filters : target)
    }

    func startDraw() {
        toogleMode(.draw)
    }

    func startText() {
        toogleMode(.text)
    }

    func finishMarkup() {
        setMode(.filters)
    }

    func updateKeyboard(h: CGFloat) {
        keyboardHeight = h
    }

    func exportFinalImage(drawingOverlay: PKDrawing? = nil) async throws {
        let data = try await makeFinalImage(drawingOverlay: drawingOverlay)
        try await exportService.saveToPhotos(data)
    }

    func share(drawingOverlay: PKDrawing?) {
        Task { @MainActor in
            print("🛠 share started")
            do {
                let item = try await makeShareItem(drawingOverlay: drawingOverlay)
                shareItem = item
            } catch {
                print("❌ share error:", error.localizedDescription)
            }
        }
    }

    func clearShareItem() {
        shareItem = nil
    }

    private func applyMode(from old: EditorMode, to new: EditorMode) {
        if new == .text, old != .text {
            textVM.enterPlacement()
        }

        if old == .text, new != .text {
            textVM.finishEditing()
        }
    }

    private func updatePreview(raw: Data?, filter: Filter?) async {
        guard let data = raw else {
            previewImage = nil
            return
        }

        let t0 = CFAbsoluteTimeGetCurrent()
        previewImage = await pipeline.makePreview(
            from: data,
            filterName: filter?.filterName,
            downscaleFactor: 0.25
        )

        let dt = CFAbsoluteTimeGetCurrent() - t0
        print("⏱ Preview render time: \(dt) sec")
    }

    private func makeFinalImage(drawingOverlay: PKDrawing?) async throws -> Data {
        guard let data = inputData, let img = originalImage, canvasSize != .zero else {
            throw OverlayRenderError.invalidBase
        }
        return try await pipeline.makeFinalImage(
            from: data,
            filterName: selectedFilter?.filterName,
            rotation: rotationCount,
            isFlipped: isFlippedHorizontally,
            drawing: drawingOverlay,
            texts: textVM.items,
            canvasSize: canvasSize,
            imageSize: img.size
        )
    }

    private func makeShareItem(drawingOverlay: PKDrawing?) async throws -> ShareItem {
        let data = try await makeFinalImage(drawingOverlay: drawingOverlay)
        let _ = try exportService.makeShareURL(from: data, format: exportFormat)
        guard let ui = UIImage(data: data) else { throw OverlayRenderError.encodeFailed }
        return ShareItem(image: ui)
    }

    // MARK: - Источники изображений: бизнес-логика (без UI-флагов)

    // Камера вернула UIImage
    func handleCameraOutput(_ uiImage: UIImage?) {
        guard let uiImage,
              let data = uiImage.jpegData(compressionQuality: 0.95) ?? uiImage.pngData()
        else { return }
        inputData = data
    }

    // Пользователь выбрал элемент в PhotosPicker
    func handleLibrarySelectionIfNeeded() {
        guard let item = libraryItem else { return }
        Task { [weak self] in
            guard let self else { return }
            do {
                if let data = try await item.loadTransferable(type: Data.self) {
                    await MainActor.run { [weak self] in
                        self?.inputData = data
                    }
                } else if let url = try await item.loadTransferable(type: URL.self) {
                    let data = try Data(contentsOf: url)
                    await MainActor.run { [weak self] in
                        self?.inputData = data
                    }
                } else if let swiftUIImage = try await item.loadTransferable(type: Image.self) {
                    let renderer = ImageRenderer(content: swiftUIImage)
                    renderer.scale = UIScreen.main.scale
                    if let uiImage = renderer.uiImage,
                       let data = uiImage.jpegData(compressionQuality: 0.95) ?? uiImage.pngData() {
                        await MainActor.run { [weak self] in
                            self?.inputData = data
                        }
                    }
                }
            } catch {
                print("❌ PhotosPicker load error:", error.localizedDescription)
            }
        }
    }
}
