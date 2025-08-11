import UIKit
import CoreImage

protocol FilterService {
    func apply(filterName: String, to data: Data, downscaleFactor: CGFloat) throws -> Data
}

enum FilterError: Error { case invalidData, renderFailed }

final class FilterServiceImpl: FilterService {

    func apply(filterName: String, to data: Data, downscaleFactor: CGFloat = 1.0) throws -> Data {

        guard var ci = CIImage(data: data) else { throw FilterError.invalidData }

        if downscaleFactor < 0.999,
           let lanczos = CIFilter(name: "CILanczosScaleTransform") {
            lanczos.setValue(ci,                forKey: kCIInputImageKey)
            lanczos.setValue(downscaleFactor,   forKey: kCIInputScaleKey)
            lanczos.setValue(1.0,               forKey: kCIInputAspectRatioKey)
            ci = lanczos.outputImage ?? ci
        }

        if !filterName.isEmpty,
           let fx = CIFilter(name: filterName) {
            fx.setValue(ci, forKey: kCIInputImageKey)
            ci = fx.outputImage ?? ci
        }

        
        guard let cg = CIContextPool.shared.createCGImage(ci, from: ci.extent)
        else { throw FilterError.renderFailed }
        
        guard let jpeg = UIImage(cgImage: cg).jpegData(compressionQuality: 0.9) else {
            throw FilterError.renderFailed
        }
        return jpeg
    }
}
