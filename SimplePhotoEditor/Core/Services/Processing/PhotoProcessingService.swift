//import Foundation
//import PencilKit
//
//protocol PhotoProcessingService {
//    func makePreview(
//        from data: Data,
//        selectedFilter: Filter?,
//        rotation: Int,
//        isFlipped: Bool,
//        crop: CGFloat
//    ) throws -> Data
//
//    func makeFinalImage(
//        from data: Data,
//        selectedFilter: Filter?,
//        rotation: Int,
//        isFlipped: Bool,
//        crop: CGFloat,
//        drawing: PKDrawing?,
//        textItems: [TextItem]
//    ) throws -> Data
//}
//
//final class PhotoProcessingServiceImpl: PhotoProcessingService {
//    private let transform: TransformService
//    private let filter:    FilterService
//    private let overlay:   OverlayRenderService
//
//    init(transform: TransformService,
//         filter:    FilterService,
//         overlay: OverlayRenderService
//    ) {
//        self.transform = transform
//        self.filter    = filter
//        self.overlay   = overlay
//    }
//
//    func makePreview(
//        from data: Data,
//        selectedFilter: Filter?,
//        rotation: Int,
//        isFlipped: Bool,
//        crop: CGFloat
//    ) throws -> Data {
//        var out = try transform.rotate90(data: data, times: rotation)
//        if isFlipped { out = try transform.flipHorizontal(data: out) }
//
//        out = try filter.apply(
//            filterName: selectedFilter?.filterName ?? "",
//            to: out,
//            downscaleFactor: 0.25
//        )
//        return out
//    }
//
//    func makeFinalImage(
//        from data: Data,
//        selectedFilter: Filter?,
//        rotation: Int,
//        isFlipped: Bool,
//        crop: CGFloat,
//        drawing: PKDrawing?,
//        textItems: [TextItem]
//    ) throws -> Data {
//        var result = data
//        if drawing != nil || !textItems.isEmpty {
//            result = try overlay.apply(drawing: drawing, text: textItems, to: result)
//        }
//        if rotation != 0 { result = try transform.rotate90(data: result, times: rotation) }
//        if isFlipped { result = try transform.flipHorizontal(data: result) }
//
//        result = try filter.apply(
//            filterName: selectedFilter?.filterName ?? "",
//            to: result,
//            downscaleFactor: 1.0
//        )
//        return result
//    }
//}
