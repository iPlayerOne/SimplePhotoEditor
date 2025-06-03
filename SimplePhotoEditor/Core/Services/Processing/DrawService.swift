import Foundation
import PencilKit
import UIKit

protocol DrawingService {
  func draw(drawing: Any, on imageData: Data) throws -> Data
}

final class DrawingServiceImpl: DrawingService {
  public init() {}

  public func draw(drawing: Any, on imageData: Data) throws -> Data {
    guard let pk = drawing as? PKDrawing else {
      throw NSError(domain: "DrawingService", code: 0)
    }
    guard let base = UIImage(data: imageData) else {
      throw NSError(domain: "DrawingService", code: 1)
    }

    let size = base.size
    let rect = CGRect(origin: .zero, size: size)
    let overlay = pk.image(from: rect, scale: base.scale)

    UIGraphicsBeginImageContextWithOptions(size, false, base.scale)
    base.draw(at: .zero)
    overlay.draw(in: rect)
    guard let combined = UIGraphicsGetImageFromCurrentImageContext(),
          let out      = combined.jpegData(compressionQuality: 1.0)
    else {
      UIGraphicsEndImageContext()
      throw NSError(domain: "DrawingService", code: 2)
    }
    UIGraphicsEndImageContext()
    return out
  }
}
