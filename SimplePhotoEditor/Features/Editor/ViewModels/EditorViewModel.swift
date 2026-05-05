import UIKit
import SwiftUI
import Combine
import PencilKit
import PhotosUI

@MainActor
final class EditorViewModel: ObservableObject {
    @Published var mode: EditorMode = .filters
    @Published var inputData: Data?
    @Published private(set) var previewImage: UIImage?
    @Published private(set) var originalImage: UIImage?

    @Published var selectedFilter: Filter?
    @Published var rotationCount: Int = 0
    @Published var isFlippedHorizontally: Bool = false

    @Published var keyboardHeight: CGFloat = 0
    @Published var canvasSize: CGSize = .zero

    @Published var shareItem: ShareItem?
    @Published var exportFormat: ExportFormat = .png
    @Published var libraryItem: PhotosPickerItem?

    var canTransformImage: Bool {
        originalImage != nil && mode == .filters
    }

    private let pipeline: ImagePipeline
    private let exportService: ExportService
    private let imageImportService: ImageImportService
    let textVM: TextOverlayViewModel

    private var cancellables = Set<AnyCancellable>()

    private var previewTask: Task<Void, Never>?
    private var previewGen = UUID()

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
                guard let self else { return }

                self.previewTask?.cancel()

                let gen = UUID()
                self.previewGen = gen

                self.previewTask = Task(priority: .userInitiated) { [weak self] in
                    guard let self else { return }
                    await self.updatePreview(raw: raw, filter: fx, gen: gen)
                }
            }
            .store(in: &cancellables)

        $inputData
            .sink { [weak self] data in
                guard let self else { return }
                self.originalImage = data.flatMap(UIImage.init(data:))
            }
            .store(in: &cancellables)
    }

    deinit {
        previewTask?.cancel()
    }

    func setMode(_ newMode: EditorMode) {
        guard newMode != mode else { return }
        applyMode(from: mode, to: newMode)
        mode = newMode
    }

    func toogleMode(_ target: EditorMode) {
        setMode(mode == target ? .filters : target)
    }

    func startDraw() { toogleMode(.draw) }
    func startText() { toogleMode(.text) }

    func updateKeyboard(h: CGFloat) { keyboardHeight = h }

    func share(drawingOverlay: PKDrawing?) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let item = try await makeShareItem(drawingOverlay: drawingOverlay)
                self.shareItem = item
            } catch { }
        }
    }

    func clearShareItem() { shareItem = nil }

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
            if textVM.items.isEmpty {
                textVM.beginPlacingNewText(rotationQuarterTurns: rotationCount)
            } else {
                textVM.finishEditing()
                textVM.isPlacing = false
            }
        }

        if old == .text, new != .text {
            textVM.finishEditing()
        }
    }

    private func updatePreview(raw: Data?, filter: Filter?, gen: UUID) async {
        guard let data = raw else {
            previewImage = nil
            return
        }

        let ui = await pipeline.makePreview(
            from: data,
            filterName: filter?.filterName,
            downscaleFactor: 0.25
        )

        if Task.isCancelled { return }
        if gen != previewGen { return }

        previewImage = ui
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
        let url = try exportService.makeShareURL(from: data, format: exportFormat)
        return ShareItem(url: url)
    }

    func handleCameraOutput(_ uiImage: UIImage?) {
        guard let data = imageImportService.dataFromCameraImage(uiImage) else { return }
        inputData = data
    }

    func handleLibrarySelectionIfNeeded() {
        guard let item = libraryItem else { return }

        defer {
            Task { [weak self] in self?.libraryItem = nil }
        }

        Task { [weak self] in
            guard let self else { return }
            do {
                if let data = try await imageImportService.loadData(from: item) {
                    self.inputData = data
                }
            } catch { }
        }
    }
}
