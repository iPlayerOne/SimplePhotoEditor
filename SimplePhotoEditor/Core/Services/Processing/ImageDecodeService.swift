import UIKit
import ImageIO

protocol ImageDecodeService {
    func decodeFull(_ data: Data)-> UIImage?
    func downsample(_ data: Data, maxDimension: CGFloat, _ scale: CGFloat)-> UIImage?
}

final class ImageDecodeServiceImpl: ImageDecodeService {
    func decodeFull(_ data: Data) -> UIImage? {
        print("🧩 [ImageDecode] decodeFull: bytes=\(data.count)")
        guard let src = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("❌ [ImageDecode] CGImageSourceCreateWithData failed")
            return nil
        }
        let type = CGImageSourceGetType(src) as String?
        let count = CGImageSourceGetCount(src)
        if let props = CGImageSourceCopyPropertiesAtIndex(src, 0, nil) as? [CFString: Any] {
            let orient = (props[kCGImagePropertyOrientation] as? NSNumber)?.intValue
            print("🧩 [ImageDecode] type=\(type ?? "nil"), frames=\(count), exifOrientation=\(orient ?? -1)")
        } else {
            print("⚠️ [ImageDecode] no properties for index 0")
        }
        guard let cg = CGImageSourceCreateImageAtIndex(src, 0, nil) else {
            print("❌ [ImageDecode] CGImageSourceCreateImageAtIndex failed")
            return nil
        }
        print("🧩 [ImageDecode] cg.size=\(cg.width)x\(cg.height)")
        return UIImage(cgImage: cg, scale: UIScreen.main.scale, orientation: .up)
    }
    
    func downsample(_ data: Data, maxDimension: CGFloat, _ scale: CGFloat) -> UIImage? {
        let srcOpts: CFDictionary = [ kCGImageSourceShouldCache: false] as CFDictionary
        let raw = maxDimension * scale
        let maxPixel = Int(raw.rounded(.down))
        let evenMaxPixel = maxPixel & ~1
        
        print("🧩 [ImageDecode] downsample: bytes=\(data.count), maxDimension=\(maxDimension), scale=\(scale), maxPixel=\(maxPixel)")
        guard let src = CGImageSourceCreateWithData(data as CFData, srcOpts) else {
            print("❌ [ImageDecode] CGImageSourceCreateWithData failed")
            return nil
        }
        let downscaleOpts: CFDictionary = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: evenMaxPixel
        ] as CFDictionary
        guard let cg = CGImageSourceCreateThumbnailAtIndex(src, 0, downscaleOpts) else {
            print("❌ [ImageDecode] CGImageSourceCreateThumbnailAtIndex failed")
            return nil
        }
        print("🧩 [ImageDecode] thumb.size=\(cg.width)x\(cg.height)")
        return UIImage(cgImage: cg, scale: scale, orientation: .up)
    }
    
    
}
