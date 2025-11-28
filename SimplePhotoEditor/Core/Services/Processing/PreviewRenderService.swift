//import UIKit
//import CoreImage
//
//protocol PreviewRenderService {
//  func renderPreview(
//    data:            Data,
//    filterName:      String?,
//    downscaleFactor: Double
//  ) throws -> UIImage
//}
//
//final class PreviewRenderServiceImpl: PreviewRenderService {
//  private let queue = DispatchQueue(
//    label: "SimplePhotoEditor.Preview",
//    qos:   .userInitiated
//  )
//
//  func renderPreview( data: Data, filterName: String?, downscaleFactor: Double ) throws -> UIImage {
//     try queue.sync {
//      guard var ci = CIImage(data: data, options: [.applyOrientationProperty: true]) else {
//        throw NSError(domain: "PreviewRender", code: -10)
//      }
//
//      if let name = filterName, !name.isEmpty, let fx = CIFilter(name: name) {
//        fx.setValue(ci, forKey: kCIInputImageKey)
//          ci = fx.outputImage ?? ci
//      }
//
//         ci = CIHelpers.lanczosScaled(ci, scale: CGFloat(downscaleFactor))
//         
//         ci = ci.snappedForDisplay()
//         let rect = ci.extent.integral
//         guard let cg = CIContextPool.shared.createCGImage(ci, from: rect) else {
//        throw NSError(domain: "PreviewRender", code: -1)
//      }
//      return UIImage(cgImage: cg)
//    }
//  }
//}
