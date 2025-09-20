import CoreImage

enum CIHelpers {
    static func lanczosScaled(_ ci: CIImage, scale: CGFloat) -> CIImage {
        guard scale < 0.999,
              let f = CIFilter(name: "CILanczosScaleTransform")
        else { return ci }
        
        let input = ci.clampedToExtent()
        f.setValue(input, forKey: kCIInputImageKey)
        f.setValue(scale, forKey: kCIInputScaleKey)
        f.setValue(1.0,   forKey: kCIInputAspectRatioKey)
        let out = f.outputImage ?? ci
        
        let scaledRect = ci.extent.applying(CGAffineTransform(scaleX: scale, y: scale))
        return out.cropped(to: scaledRect)
    }
}

extension CIImage {
    func snappedForDisplay() -> CIImage {
        let r = self.extent.integral
        let snapped = CGRect(
            x: floor(r.origin.x),
            y: floor(r.origin.y),
            width: round(r.size.width),
            height: round(r.size.height)
        )
        if snapped == r {
            return self.cropped(to: snapped)
        }
        return self
            .transformed(by: CGAffineTransform(translationX: -snapped.origin.x,
                                               y: -snapped.origin.y))
            .cropped(to: CGRect(origin: .zero, size: snapped.size))
    }
}

