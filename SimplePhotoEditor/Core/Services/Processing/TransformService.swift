import UIKit
import CoreImage
import CoreGraphics

protocol TransformService {
    func rotate90(data: Data, times: Int) throws -> Data
    func flipHorizontal(data: Data) throws -> Data
}

enum TransformError: Error {
    case invalidData, renderFailed, encodeFailed
}


final class TransformServiceImpl: TransformService {
    private let ctx = CIContext()

    func rotate90(data: Data, times: Int) throws -> Data {
        guard let ci = CIImage(data: data) else { throw TransformError.invalidData }
        let angle = CGFloat(times % 4) * .pi/2
        let rotated = ci.transformed(by: .init(rotationAngle: angle))
        return try render(ci: rotated)
    }

    func flipHorizontal(data: Data) throws -> Data {
        guard let ci = CIImage(data: data) else { throw TransformError.invalidData }
        let flipped = ci
            .transformed(by: .init(scaleX: -1, y: 1))
            .transformed(by: .init(translationX: -ci.extent.width, y: 0))
        return try render(ci: flipped)
    }

    // helper
    private func render(ci: CIImage) throws -> Data {
        guard let cg = ctx.createCGImage(ci, from: ci.extent),
              let out = UIImage(cgImage: cg).jpegData(compressionQuality: 1)
        else { throw TransformError.renderFailed }
        return out
    }
}
