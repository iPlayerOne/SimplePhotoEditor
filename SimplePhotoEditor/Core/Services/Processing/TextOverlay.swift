import Foundation

protocol TextOverlayService {
    func overlay(
        items: [TextItem],
        on data: Data
    ) throws -> Data
}

enum TextOverlayError: Error {
    case invalidData, contextFailed, encodeFailed
}

import Foundation
import UIKit

final class TextOverlayServiceImpl: TextOverlayService {
    func overlay(items: [TextItem], on data: Data) throws -> Data {
        guard let baseImage = UIImage(data: data) else {
            throw TextOverlayError.invalidData
        }
        let size = baseImage.size
        UIGraphicsBeginImageContextWithOptions(size, false, baseImage.scale)
        defer { UIGraphicsEndImageContext() }

        baseImage.draw(at: .zero)

        for item in items {
            let font = item.font.uiFont(size: CGFloat(item.fontSize))
             let color = item.color.uiColor

             let attrs: [NSAttributedString.Key: Any] = [
                 .font: font,
                 .foregroundColor: color
             ]
            let ns = NSString(string: item.text)
            let textSize = ns.size(withAttributes: attrs)
            let origin = CGPoint(
                x: item.position.x - textSize.width/2,
                y: item.position.y - textSize.height/2
            )
            ns.draw(at: origin, withAttributes: attrs)
        }

        guard let combined = UIGraphicsGetImageFromCurrentImageContext(),
              let pngData  = combined.pngData() else {
            throw TextOverlayError.encodeFailed
        }
        return pngData
    }
}
