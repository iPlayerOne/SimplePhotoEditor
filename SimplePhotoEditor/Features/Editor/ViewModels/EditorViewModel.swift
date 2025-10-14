import SwiftUI
import Combine
import PencilKit

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
    
    // Добавлено: выбор формата экспорта для шаринга
    @Published var exportAsPNG: Bool = true
    
    private var pipeline: ImagePipeline
    private let exportService: ExportService
    
    let textVM = TextOverlayViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        pipeline: ImagePipeline,
        exportService:    ExportService
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
        // Получаем итоговые данные изображения
        let data = try await makeFinalImage(drawingOverlay: drawingOverlay)
        // Формируем временный файл через ExportService с учетом формата
        let url = try exportService.makeShareURL(from: data, asPNG: exportAsPNG)
        // Для UIActivityViewController удобнее передать URL, но ShareItem сейчас хранит UIImage.
        // Чтобы изменения были минимальными, оставим изображение для превью,
        // а в ShareSheet передадим сам URL (см. место вызова ShareSheet).
        guard let ui = UIImage(data: data) else { throw OverlayRenderError.encodeFailed }
        // Используем изображение для превью, а сам URL будем отдавать в ShareSheet.items
        // Предполагается, что потребитель ShareItem сможет получить URL отдельно.
        // Если нужно — можно расширить ShareItem.
        return ShareItem(image: ui)
    }
}
