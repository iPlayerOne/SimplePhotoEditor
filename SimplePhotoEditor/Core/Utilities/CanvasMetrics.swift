import SwiftUI

struct CanvasMetrics {
    let w: CGFloat
    let h: CGFloat
    let canvasSize: CGSize
    let containerSize: CGSize
    
    init(
        geo: GeometryProxy,
        baseImage: UIImage?,
        bottomChrome: CGFloat,
        heightRatio: CGFloat,
        displayScale: CGFloat
    ) {
            let scale = displayScale
            let containerW = snapToPixel(geo.size.width,              scale: scale)
            let availableHeight = geo.size.height * heightRatio - bottomChrome
            let containerH = snapToPixel(availableHeight, scale: scale)

            self.containerSize = CGSize(width: containerW, height: containerH)

            if let img = baseImage, img.size.width > 0, img.size.height > 0 {
                let s    = min(containerW / img.size.width, containerH / img.size.height)
                let fitW = snapToPixel(img.size.width  * s, scale: scale)
                let fitH = snapToPixel(img.size.height * s, scale: scale)
                self.w = fitW
                self.h = fitH
            } else {
                self.w = containerW
                self.h = containerH
            }
            self.canvasSize = CGSize(width: w, height: h)
    }
}
