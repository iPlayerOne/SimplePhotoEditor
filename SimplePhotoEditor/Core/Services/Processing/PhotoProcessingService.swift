import Foundation

protocol PhotoProcessingService {
    func makePreview(
        from data: Data,
        selectedFilter: Filter?,
        rotation: Int,
        isFlipped: Bool,
        crop: CGFloat
    ) throws -> Data

    func makeFinalImage(
        from data: Data,
        selectedFilter: Filter?,
        rotation: Int,
        isFlipped: Bool,
        crop: CGFloat,
        drawingOverlay: Data?,
        textItems: [TextItem]
    ) throws -> Data
}

final class PhotoProcessingServiceImpl: PhotoProcessingService {
    private let transform: TransformService
    private let filter:    FilterService
    private let compose:   ImageComposeService
    private let text:      TextOverlayService

    init(transform: TransformService,
         filter:    FilterService,
         compose:   ImageComposeService,
         text:      TextOverlayService) {
        self.transform = transform
        self.filter    = filter
        self.compose   = compose
        self.text      = text
    }

    func makePreview(
        from data: Data,
        selectedFilter: Filter?,
        rotation: Int,
        isFlipped: Bool,
        crop: CGFloat
    ) throws -> Data {
        var out = try transform.rotate90(data: data, times: rotation)
        if isFlipped { out = try transform.flipHorizontal(data: out) }

        out = try filter.apply(
            filterName: selectedFilter?.filterName ?? "",
            to: out,
            downscaleFactor: 0.25
        )
        return out
    }

    // MARK: – Final
    func makeFinalImage(
        from data: Data,
        selectedFilter: Filter?,
        rotation: Int,
        isFlipped: Bool,
        crop: CGFloat,
        drawingOverlay: Data?,
        textItems: [TextItem]
    ) throws -> Data {
        var result = try transform.rotate90(data: data, times: rotation)
        if isFlipped { result = try transform.flipHorizontal(data: result) }

        result = try filter.apply(
            filterName: selectedFilter?.filterName ?? "",
            to: result,
            downscaleFactor: 1.0
        )

        if let overlay = drawingOverlay {
            result = try compose.merge(base: result, overlayPNG: overlay)
        }
        if !textItems.isEmpty {
            result = try text.overlay(items: textItems, on: result)
        }
        return result
    }
}
