import UIKit
import PencilKit

protocol ImagePipeline {
    func makePreview(from data: Data, filterName: String?, downscaleFactor: CGFloat) async -> UIImage?
    func makeFinalImage(
        from data: Data,
        filterName: String?,
        rotation: Int,
        isFlipped: Bool,
        drawing: PKDrawing?,
        texts: [TextItem]?,
        canvasSize: CGSize,
        imageSize: CGSize
    ) async throws -> Data
}

final class ImagePipelineImpl: ImagePipeline {
    private let decode: ImageDecodeService
    private let transform: TransformService
    private let filter: FilterService
    private let overlay: OverlayRenderService

    init(decode: ImageDecodeService, transform: TransformService, filter: FilterService, overlay: OverlayRenderService) {
        self.decode = decode
        self.transform = transform
        self.filter = filter
        self.overlay = overlay
    }

    func makePreview(from data: Data, filterName: String?, downscaleFactor: CGFloat) async -> UIImage? {
        await Task(priority: .userInitiated) { [decode, filter] in
            if Task.isCancelled { return nil }

            let scale = UIScreen.main.scale
            guard let preview = decode.downsample(data, maxDimension: 600, scale) else {
                return nil
            }

            guard let name = filterName, !name.isEmpty else {
                return preview
            }

            if Task.isCancelled { return nil }

            guard
                let jpeg = preview.jpegData(compressionQuality: 0.9),
                let filteredData = try? filter.apply(filterName: name, to: jpeg, downscaleFactor: downscaleFactor),
                let filteredPreview = UIImage(data: filteredData)
            else {
                return preview
            }

            return filteredPreview
        }.value
    }

    func makeFinalImage(
        from data: Data,
        filterName: String?,
        rotation: Int,
        isFlipped: Bool,
        drawing: PKDrawing?,
        texts: [TextItem]?,
        canvasSize: CGSize,
        imageSize: CGSize
    ) async throws -> Data {
        try await Task(priority: .userInitiated) { [transform, filter, overlay] in
            var out = data

            if rotation != 0 {
                out = try transform.rotate90(data: out, times: rotation)
            }
            if isFlipped {
                out = try transform.flipHorizontal(data: out)
            }

            if let name = filterName, !name.isEmpty {
                out = try filter.apply(filterName: name, to: out, downscaleFactor: 1.0)
            }

            let hasTexts = !(texts?.isEmpty ?? true)
            if drawing != nil || hasTexts {
                out = try overlay.apply(
                    drawing: drawing,
                    texts: texts,
                    to: out,
                    canvasSize: canvasSize,
                    imageSize: imageSize
                )
            }

            return out
        }.value
    }
}
