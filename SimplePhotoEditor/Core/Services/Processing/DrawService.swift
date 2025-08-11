import PencilKit
import UIKit

enum DrawingServiceError: Error {
    case invalidDrawing
    case invalidBaseImage
    case renderFailed
}

protocol DrawingService {
  func draw(drawing: PKDrawing, on baseData: Data) throws -> Data
}

final class DrawingServiceImpl: DrawingService {
    func draw(drawing: PKDrawing, on baseData: Data) throws -> Data {
        guard let base = UIImage(data: baseData) else {
            throw DrawingServiceError.invalidBaseImage
        }
        
        let size  = CGSize(width: base.size.width  * base.scale,
                           height: base.size.height * base.scale)
        let rect  = CGRect(origin: .zero, size: size)
        
        let overlay = drawing.image(from: rect, scale: base.scale)
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let combined = renderer.jpegData(withCompressionQuality: 0.95) { ctx in
            base.draw(in: rect)
            overlay.draw(in: rect)
        }
        return combined
    }
}
