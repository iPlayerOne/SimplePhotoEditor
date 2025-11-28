import UIKit
import ImageIO

protocol ImageDecodeService {
    func decodeFull(_ data: Data)-> UIImage?
    func downsample(_ data: Data, maxDimension: CGFloat, _ scale: CGFloat)-> UIImage?
}

final class ImageDecodeServiceImpl: ImageDecodeService {
    func decodeFull(_ data: Data) -> UIImage? {
        guard let src = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        let type = CGImageSourceGetType(src) as String?
        let count = CGImageSourceGetCount(src)
        if let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any] {
            let orient = (props[kCGImagePropertyOrientation] as? NSNumber)?.intValue
            let _ = (type, count, orient)
        }
        guard let cg = CGImageSourceCreateImageAtIndex(src, 0, nil) else {
            return nil
        }
        return UIImage(cgImage: cg, scale: UIScreen.main.scale, orientation: .up)
    }
    
    func downsample(_ data: Data, maxDimension: CGFloat, _ scale: CGFloat) -> UIImage? {
        let srcOpts: CFDictionary = [ kCGImageSourceShouldCache: false] as CFDictionary
        let raw = maxDimension * scale
        let maxPixel = Int(raw.rounded(.down))
        let evenMaxPixel = maxPixel & ~1
        
        guard let src = CGImageSourceCreateWithData(data as CFData, srcOpts) else {
            return nil
        }
        let downscaleOpts: CFDictionary = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: evenMaxPixel
        ] as CFDictionary
        guard let cg = CGImageSourceCreateThumbnailAtIndex(src, 0, downscaleOpts) else {
            return nil
        }
        return UIImage(cgImage: cg, scale: scale, orientation: .up)
    }
    
    
}
