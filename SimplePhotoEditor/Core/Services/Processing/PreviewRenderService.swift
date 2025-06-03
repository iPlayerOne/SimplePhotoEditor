import UIKit
import CoreImage

protocol PreviewRenderService {
  func renderPreview(
    data:            Data,
    filterName:      String?,
    downscaleFactor: Double    // 0…1
  ) throws -> UIImage
}

final class PreviewRenderServiceImpl: PreviewRenderService {
  private let ctx = CIContext(options: [.cacheIntermediates: false])
  private let queue = DispatchQueue(
    label: "SimplePhotoEditor.Preview",
    qos:   .userInitiated
  )

  func renderPreview(
    data: Data,
    filterName: String?,
    downscaleFactor: Double
  ) throws -> UIImage {
    return try queue.sync {
      // 1) CIImage с учётом EXIF-ориентации
      var ci = CIImage(
        data:    data,
        options: [.applyOrientationProperty: true]
      )!

      // 2) Пользовательский фильтр (если есть)
      if let name = filterName, !name.isEmpty,
         let fx = CIFilter(name: name) {
        fx.setValue(ci, forKey: kCIInputImageKey)
        ci = fx.outputImage ?? ci
      }

      // 3) Даун-скейл Lanczos
      if downscaleFactor < 0.999,
         let lanczos = CIFilter(name: "CILanczosScaleTransform") {
        lanczos.setValue(ci,               forKey: kCIInputImageKey)
        lanczos.setValue(downscaleFactor,  forKey: kCIInputScaleKey)
        lanczos.setValue(1.0,              forKey: kCIInputAspectRatioKey)
        ci = lanczos.outputImage ?? ci
      }

      // 4) Рендер в UIImage(.up)
      guard let cg = ctx.createCGImage(ci, from: ci.extent) else {
        throw NSError(domain: "PreviewRender", code: -1)
      }
      return UIImage(cgImage: cg)
    }
  }
}
