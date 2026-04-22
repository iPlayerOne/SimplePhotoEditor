import UIKit
import CoreImage

protocol FilterService {
    func apply(filterName: String, to data: Data, downscaleFactor: CGFloat) throws -> Data
}

enum FilterError: Error { case invalidData, renderFailed }

final class FilterServiceImpl: FilterService {

    func apply(filterName: String, to data: Data, downscaleFactor: CGFloat = 1.0) throws -> Data {
        try apply(filterName: filterName, to: data, downscaleFactor: downscaleFactor, context: CIContextPool.final)
    }

    func applyPreview(filterName: String, to data: Data, downscaleFactor: CGFloat = 1.0) throws -> Data {
        try apply(filterName: filterName, to: data, downscaleFactor: downscaleFactor, context: CIContextPool.preview)
    }

    private func apply(
        filterName: String,
        to data: Data,
        downscaleFactor: CGFloat,
        context: CIContext
    ) throws -> Data {

        guard var ci = CIImage(data: data, options: [.applyOrientationProperty: true]) else {
            throw FilterError.invalidData
        }

        ci = CIHelpers.lanczosScaled(ci, scale: downscaleFactor)

        let originalExtent = ci.extent.integral
        let clamped = ci.clampedToExtent()

        if !filterName.isEmpty, let fx = CIFilter(name: filterName) {
            fx.setValue(clamped, forKey: kCIInputImageKey)
            if let out = fx.outputImage {
                ci = out.cropped(to: originalExtent)
            }
        }

        let rect = ci.extent.integral
        guard let cg = context.createCGImage(ci, from: rect) else {
            throw FilterError.renderFailed
        }

        guard let jpeg = UIImage(cgImage: cg).jpegData(compressionQuality: 0.9) else {
            throw FilterError.renderFailed
        }

        return jpeg
    }
}
