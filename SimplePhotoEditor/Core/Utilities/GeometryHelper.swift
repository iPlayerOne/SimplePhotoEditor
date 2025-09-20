import CoreGraphics

@inlinable
func aspectFitRect(aspect: CGSize, in bounding: CGRect) -> CGRect {
    guard aspect.width > 0, aspect.height > 0, bounding.width > 0, bounding.height > 0 else { return .zero }
    
    let scale = min(bounding.width / aspect.width, bounding.height / aspect.height)
    let size  = CGSize(width: aspect.width * scale, height: aspect.height * scale)
    let origin = CGPoint(x: bounding.midX - size.width / 2, y: bounding.midY - size.height / 2)
    
    return CGRect(origin: origin, size: size)
}
