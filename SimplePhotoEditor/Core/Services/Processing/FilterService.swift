import UIKit
import CoreImage

protocol FilterService {
    func apply(
        filterName: String,
        to data: Data,
        downscaleFactor: CGFloat
    ) throws -> Data
}

enum FilterError: Error { case invalidData, renderFailed }

final class FilterServiceImpl: FilterService {

    func apply(filterName: String,
               to data: Data,
               downscaleFactor: CGFloat = 1.0) throws -> Data {

        guard var ci = CIImage(data: data) else { throw FilterError.invalidData }

        // ---------- 1. Lanczos down‑scale ----------
        if downscaleFactor < 0.999,
           let lanczos = CIFilter(name: "CILanczosScaleTransform") {
            lanczos.setValue(ci,                forKey: kCIInputImageKey)
            lanczos.setValue(downscaleFactor,   forKey: kCIInputScaleKey)
            lanczos.setValue(1.0,               forKey: kCIInputAspectRatioKey)
            ci = lanczos.outputImage ?? ci
        }

        // ---------- 2. Пользовательский фильтр ----------
        if !filterName.isEmpty,
           let fx = CIFilter(name: filterName) {
            fx.setValue(ci, forKey: kCIInputImageKey)
            ci = fx.outputImage ?? ci
        }

        // ---------- 3. Рендер одним CIContext ----------
        guard let cg = CIContextPool.shared.createCGImage(ci, from: ci.extent)
        else { throw FilterError.renderFailed }

        return UIImage(cgImage: cg).pngData() ?? data
    }
}
