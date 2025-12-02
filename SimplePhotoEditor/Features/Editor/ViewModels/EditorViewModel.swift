import SwiftUI
import Combine
import PencilKit
import PhotosUI
import UIKit


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
    @Published var exportFormat: ExportFormat = .png
    @Published var libraryItem: PhotosPickerItem?

    private var pipeline: ImagePipeline
    private let exportService: ExportService
    private let imageImportService: ImageImportService
    let textVM: TextOverlayViewModel

    private var cancellables = Set<AnyCancellable>()

    init(
        pipeline: ImagePipeline,
        exportService: ExportService,
        textVM: TextOverlayViewModel,
        imageImportService: ImageImportService
    ) {
        self.pipeline = pipeline
        self.exportService = exportService
        self.textVM = textVM
        self.imageImportService = imageImportService

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

    func updateKeyboard(h: CGFloat) {
        keyboardHeight = h
    }

    func share(drawingOverlay: PKDrawing?) {
        Task {
            do {
                let item = try await makeShareItem(drawingOverlay: drawingOverlay)
                shareItem = item
            } catch {
            }
        }
    }

    func clearShareItem() {
        shareItem = nil
    }
    
    func resetForNewImage() {
        mode = .filters
        selectedFilter = nil
        rotationCount = 0
        isFlippedHorizontally = false
        shareItem = nil
        textVM.reset()
        textVM.finishEditing()
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

        let _ = CFAbsoluteTimeGetCurrent() - t0
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

    func handleCameraOutput(_ uiImage: UIImage?) {
        guard let data = imageImportService.dataFromCameraImage(uiImage) else { return }
        inputData = data
    }

    func handleLibrarySelectionIfNeeded() {
        guard let item = libraryItem else { return }
        
        defer {
            Task {
                self.libraryItem = nil  
            }
        }
        
        Task { [weak self] in
            guard let self else { return }
            do {
                if let data = try await imageImportService.loadData(from: item) {
                    await MainActor.run { [weak self] in
                        self?.inputData = data
                    }
                }
            } catch {
            }
        }
    }
}
