// EditorViewModel.swift

import SwiftUI
import Combine

@MainActor
final class EditorViewModel: ObservableObject {
    @Published var markup: MarkupTool = .none

    @Published var keyboardHeight: CGFloat = 0
    @Published var inputData: Data?
    @Published var selectedFilter: Filter? = nil
    @Published private(set) var previewImage: UIImage? = nil
    @Published var canvasSize: CGSize = .zero
    @Published var rotationCount = 0
    @Published var isFlippedHorizontally = false
    @Published private(set) var originalImage: UIImage? = nil
    @Published var shareItem: ShareItem?

    let textVM = TextOverlayViewModel()

    private let transformService: TransformService
    private let filterService:    FilterService
    private let composeService:   ImageComposeService
    private let textService:      TextOverlayService
    private let exportService:    ExportService
    private let previewService:   PreviewRenderService

    private var cancellables = Set<AnyCancellable>()

    init(
        transformService: TransformService,
        filterService:    FilterService,
        composeService:   ImageComposeService,
        textService:      TextOverlayService,
        exportService:    ExportService,
        previewService:   PreviewRenderService = PreviewRenderServiceImpl()
    ) {
        self.transformService = transformService
        self.filterService    = filterService
        self.composeService   = composeService
        self.textService      = textService
        self.exportService    = exportService
        self.previewService   = previewService

        Publishers
          .CombineLatest($inputData, $selectedFilter)
          .debounce(for: .milliseconds(120), scheduler: RunLoop.main)
          .sink { [weak self] raw, fx in
              self?.updatePreview(raw: raw, filter: fx)
          }
          .store(in: &cancellables)

        $inputData
            .sink { [weak self] data in
                guard let data else { self?.originalImage = nil; return }
                self?.originalImage = UIImage(data: data)
            }
            .store(in: &cancellables)

        Publishers.CombineLatest($originalImage, $selectedFilter)
            .sink { [weak self] image, filter in
                guard let self = self else { return }
                self.previewImage = self.apply(filter: filter, to: image)
            }
            .store(in: &cancellables)
    }

    private func updatePreview(raw: Data?, filter: Filter?) {
        guard let data = raw else {
            previewImage = nil
            return
        }
        Task.detached(priority: .userInitiated) { [previewService] in
            let ui = try? previewService.renderPreview(
                data: data,
                filterName: filter?.filterName,
                downscaleFactor: 0.25
            )
            await MainActor.run { self.previewImage = ui }
        }
    }

    func startDraw() {
        markup = .draw
        textVM.finishEditing()
    }

    func startText() {
        markup = .text
        textVM.enterPlacement()
    }

    func finishMarkup() {
        markup = .none
        textVM.finishEditing()
    }

    func updateKeyboard(h: CGFloat) {
        keyboardHeight = h
    }

    func exportFinalImage(drawingOverlay: Data? = nil) async throws {
        let data = try await renderFinalImage(drawingOverlay: drawingOverlay)
        try await exportService.saveToPhotos(data)
    }
    
    func share(drawingOverlay: Data?) {
        Task { @MainActor in
            print("🛠 share started")
            do {
                let item = try await makeShareItem(drawingOverlay: drawingOverlay)
                shareItem = item
                print("✅ shareItem set:", shareItem?.url.absoluteString ?? "nil")
            } catch {
                print("❌ share error:", error.localizedDescription)
            }
        }
    }
    
    func clearShareItem() {
        if let item = shareItem {
            try? FileManager.default.removeItem(at: item.url)
            shareItem = nil
        }
    }
    

    private func renderFinalImage(drawingOverlay: Data?) async throws -> Data {
        print("🔬 renderFinalImage called")
        guard let raw = inputData else { 
            print("❌ Нет inputData!")
            throw TransformError.invalidData 
        }
        var img = raw

        if rotationCount != 0 {
            img = try transformService.rotate90(data: img, times: rotationCount)
        }
        if isFlippedHorizontally {
            img = try transformService.flipHorizontal(data: img)
        }

        img = try filterService.apply(
            filterName: selectedFilter?.filterName ?? "",
            to: img,
            downscaleFactor: 1.0
        )

        if let overlay = drawingOverlay, !overlay.isEmpty {
            print("🖌 overlay bytes:", overlay.count)
            do {
                img = try composeService.merge(base: img, overlayPNG: overlay)
            } catch {
                print("❌ composeService.merge error:", error)
                throw error
            }
        } else {
            print("ℹ️ overlay is nil or empty, skip merge")
        }
        print("🔬 renderFinalImage done, data size:", img.count)
        return img
    }

    private func apply(filter: Filter?, to image: UIImage?) -> UIImage? {
        guard let image = image else { return nil }
        guard let filter = filter, !filter.filterName.isEmpty else { return image }
        guard let ciImage = CIImage(image: image), let fx = CIFilter(name: filter.filterName) else { return image }
        fx.setValue(ciImage, forKey: kCIInputImageKey)
        let context = CIContext()
        if let outputCIImage = fx.outputImage,
           let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) {
            return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
        } else {
            return image
        }
    }

    private func makeShareItem(drawingOverlay: Data?) async throws -> ShareItem {
        print("🔧 makeShareItem called")
        let data = try await renderFinalImage(drawingOverlay: drawingOverlay)
        let url = try exportService.makeShareURL(from: data)
        print("🔧 makeShareItem url:", url.absoluteString)
        return ShareItem(url: url)
    }
}
