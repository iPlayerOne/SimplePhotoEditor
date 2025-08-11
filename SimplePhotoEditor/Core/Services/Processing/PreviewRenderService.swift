import UIKit
import CoreImage

protocol PreviewRenderService {
  func renderPreview(
    data:            Data,
    filterName:      String?,
    downscaleFactor: Double
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
      print("🖼️ [Preview] renderPreview begin: bytes=\(data.count), filter=\(filterName ?? "nil"), scale=\(downscaleFactor)")

      guard var ci = CIImage(data: data, options: [.applyOrientationProperty: true]) else {
        print("❌ [Preview] CIImage(data:) failed")
        throw NSError(domain: "PreviewRender", code: -10)
      }
      print("🖼️ [Preview] input extent: \(ci.extent)")

      if let name = filterName, !name.isEmpty, let fx = CIFilter(name: name) {
        fx.setValue(ci, forKey: kCIInputImageKey)
        if let out = fx.outputImage {
          ci = out
          print("🖼️ [Preview] filter \(name) applied, extent: \(ci.extent)")
        } else {
          print("⚠️ [Preview] filter \(name) produced nil output — skipping")
        }
      }

      if downscaleFactor < 0.999, let lanczos = CIFilter(name: "CILanczosScaleTransform") {
        lanczos.setValue(ci,              forKey: kCIInputImageKey)
        lanczos.setValue(downscaleFactor, forKey: kCIInputScaleKey)
        lanczos.setValue(1.0,             forKey: kCIInputAspectRatioKey)
        if let out = lanczos.outputImage {
          ci = out
          print("🖼️ [Preview] downscaled by \(downscaleFactor), extent: \(ci.extent)")
        } else {
          print("⚠️ [Preview] lanczos produced nil output — skipping")
        }
      }

      guard let cg = ctx.createCGImage(ci, from: ci.extent) else {
        print("❌ [Preview] ctx.createCGImage failed")
        throw NSError(domain: "PreviewRender", code: -1)
      }
      print("✅ [Preview] success cg: \(cg.width)x\(cg.height)")
      return UIImage(cgImage: cg)
    }
  }
}
