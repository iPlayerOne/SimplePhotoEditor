import UIKit
import ImageIO

protocol ImageDecodeService {
    func downsample(_ data: Data, maxDimension: CGFloat, _ scale: CGFloat) -> UIImage?
    func downsampleCGImage(_ data: Data, maxPixelSize: Int) -> CGImage?
}

final class ImageDecodeServiceImpl: ImageDecodeService {

    func downsample(_ data: Data, maxDimension: CGFloat, _ scale: CGFloat) -> UIImage? {
        let maxPixelSize = makeMaxPixelSize(maxDimension: maxDimension, scale: scale)
        guard let cg = downsampleCGImage(data, maxPixelSize: maxPixelSize) else { return nil }
        return UIImage(cgImage: cg, scale: scale, orientation: .up)
    }

    func downsampleCGImage(_ data: Data, maxPixelSize: Int) -> CGImage? {
        let srcOpts: CFDictionary = [
            kCGImageSourceShouldCache: false
        ] as CFDictionary

        guard let src = CGImageSourceCreateWithData(data as CFData, srcOpts) else {
            return nil
        }

        let evenMaxPixel = max(2, maxPixelSize & ~1)

        let thumbOpts: CFDictionary = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: evenMaxPixel,
            kCGImageSourceShouldCacheImmediately: true
        ] as CFDictionary

        return CGImageSourceCreateThumbnailAtIndex(src, 0, thumbOpts)
    }

    private func makeMaxPixelSize(maxDimension: CGFloat, scale: CGFloat) -> Int {
        let raw = maxDimension * max(1, scale)
        let maxPixel = Int(raw.rounded(.down))
        return max(2, maxPixel)
    }
}
