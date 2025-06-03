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

        // Рисуем фон
        baseImage.draw(at: .zero)

        // Рисуем каждый текст
        for item in items {
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: item.fontName, size: item.fontSize)
                        ?? UIFont.systemFont(ofSize: item.fontSize),
                .foregroundColor: item.color
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
