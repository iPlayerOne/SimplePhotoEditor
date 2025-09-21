import UIKit
import PencilKit
import UniformTypeIdentifiers
import ImageIO

protocol OverlayRenderService {
    func apply(drawing: PKDrawing?, texts: [TextItem]?, to data: Data, canvasSize: CGSize, imageSize: CGSize) throws -> Data
}

enum OverlayRenderError: Error {
    case invalidBase
    case encodeFailed
}

final class OverlayRenderServiceImpl: OverlayRenderService {
    
    func apply(drawing: PKDrawing?, texts: [TextItem]?, to data: Data, canvasSize: CGSize, imageSize: CGSize) throws -> Data {
        let base = try decodeBaseImage(from: data)
        
        let mapping = CanvasMapping(canvasSize: canvasSize, imageSize: imageSize, baseSize: base.size)
        
        let rendered = render(base: base, drawing: drawing, texts: texts, mapping: mapping)
        
        return try encodeJPEG(rendered, quality: 0.9)
    }
    
    private func decodeBaseImage(from data: Data) throws -> UIImage {
        guard let img = UIImage(data: data) else {
            throw OverlayRenderError.invalidBase
        }
        return img
    }
    
    private func encodeJPEG(_ image: UIImage, quality: CGFloat) throws -> Data {
        guard let out = image.jpegData(compressionQuality: quality) else {
            throw OverlayRenderError.encodeFailed
        }
        return out
    }
    
    private func render(base: UIImage, drawing: PKDrawing?, texts: [TextItem]?, mapping: CanvasMapping) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = base.scale
        format.opaque = true
        
        let renderer = UIGraphicsImageRenderer(size: base.size, format: format)
        
        return renderer.image { ctx in
            drawBase(base, in: ctx)
            
            if let drawing {
                drawDrawing(drawing, in: ctx, mapping: mapping)
            }
            if let texts, !texts.isEmpty {
                drawTexts(texts, in: ctx, mapping: mapping)
            }
        }
    }
    
    private func drawBase(_ base: UIImage, in ctx: UIGraphicsImageRendererContext) {
        base.draw(in: CGRect(origin: .zero, size: base.size))
    }
    
    private func drawDrawing(_ drawing: PKDrawing, in ctx: UIGraphicsImageRendererContext, mapping: CanvasMapping) {
        let overlay = drawing.image(from: CGRect(origin: .zero, size: mapping.canvasSize), scale: 1.0)
        
        ctx.cgContext.saveGState()
        ctx.cgContext.translateBy(
            x: -mapping.rectOnCanvas.minX * mapping.scaleToImage,
            y: -mapping.rectOnCanvas.minY * mapping.scaleToImage
        )
        ctx.cgContext.scaleBy(x: mapping.scaleToImage, y: mapping.scaleToImage)
        
        overlay.draw(in: CGRect(origin: .zero, size: mapping.canvasSize))
        ctx.cgContext.restoreGState()
    }
    
    private func drawTexts(_ items: [TextItem], in ctx: UIGraphicsImageRendererContext, mapping: CanvasMapping) {
        for item in items {
            let pt = mapping.canvasToImage(item.position)
            let fontSize = CGFloat(item.fontSize) * mapping.scaleToImage
            let attrs: [NSAttributedString.Key: Any] = [
                .font : item.font.uiFont(size: fontSize),
                .foregroundColor: item.color.uiColor
            ]
            let ns = item.text as NSString
            let ts = ns.size(withAttributes: attrs)
            let origin = CGPoint(x: pt.x - ts.width / 2, y: pt.y - ts.height / 2)
            ns.draw(at: origin, withAttributes: attrs)
        }
    }
}

private struct CanvasMapping {
    let canvasSize: CGSize
    let imageSize: CGSize
    let baseSize: CGSize
    
    let rectOnCanvas: CGRect
    let scaleToImage: CGFloat
    
    init(canvasSize: CGSize, imageSize: CGSize, baseSize: CGSize) {
        self.canvasSize = canvasSize
        self.imageSize = imageSize
        self.baseSize = baseSize
        
        let imgAspect = imageSize.width / max(imageSize.height, 0.0001)
        let canvasAspect = canvasSize.width / max(canvasSize.height, 0.0001)
        
        if imgAspect > canvasAspect {
            let w = canvasSize.width
            let h = w / imgAspect
            let y = (canvasSize.height - h) / 2
            self.rectOnCanvas = CGRect(x: 0, y: y, width: w, height: h)
        } else {
            let h = canvasSize.height
            let w = h * imgAspect
            let x = (canvasSize.width - w) / 2
            self.rectOnCanvas = CGRect(x: x, y: 0, width: w, height: h)
        }
        
        self.scaleToImage = baseSize.width / rectOnCanvas.width
    }
    
    func canvasToImage(_ p: CGPoint) -> CGPoint {
        return CGPoint(
            x: (p.x - rectOnCanvas.minX) * scaleToImage,
            y: (p.y - rectOnCanvas.minY) * scaleToImage
        )
    }
}
