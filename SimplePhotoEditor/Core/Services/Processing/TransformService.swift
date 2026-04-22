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
    private let ctx = CIContextPool.final

    func rotate90(data: Data, times: Int) throws -> Data {
        guard let ci0 = CIImage(data: data, options: [.applyOrientationProperty: true])
        else { throw TransformError.invalidData }

        let angle = CGFloat(times % 4) * .pi / 2
        let rotated = ci0.transformed(by: .init(rotationAngle: angle))
                          .snappedForDisplay()

        return try render(ci: rotated)
    }

    func flipHorizontal(data: Data) throws -> Data {
        guard let ci0 = CIImage(data: data, options: [.applyOrientationProperty: true])
        else { throw TransformError.invalidData }

        let flipped = ci0
            .transformed(by: .init(scaleX: -1, y: 1))
            .transformed(by: .init(translationX: -ci0.extent.width, y: 0))
            .snappedForDisplay()

        return try render(ci: flipped)
    }

    private func render(ci: CIImage) throws -> Data {
        let rect = ci.extent.integral
        guard let cg = ctx.createCGImage(ci, from: rect) else {
            throw TransformError.renderFailed
        }
        guard let out = UIImage(cgImage: cg, scale: 1, orientation: .up)
                .jpegData(compressionQuality: 1) else {
            throw TransformError.encodeFailed
        }
        return out
    }
}
