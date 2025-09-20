import SwiftUI

struct CanvasMetrics {
    let w: CGFloat
    let h: CGFloat
    let canvasSize: CGSize
    
    let containerH: CGFloat
    let containerSize: CGSize
    
    init(geo: GeometryProxy, baseImage: UIImage?, bottomChrome: CGFloat, heightRatio: CGFloat) {
            let scale = UIScreen.main.scale

            // <- главное изменение: НЕ вычитаем bottomChrome
            let containerW = snapToPixel(geo.size.width,              scale: scale)
            let containerH = snapToPixel(geo.size.height * heightRatio, scale: scale)

            self.containerH   = containerH
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

            print("📐 container=\(containerSize) image=\(baseImage?.size ?? .zero) fit=\(canvasSize)")
    }
}
