import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

protocol ImageComposeService {
    func merge(base: Data, overlayPNG: Data) throws -> Data
}

enum ImageComposeError: Error { case decode, render, encode }

final class ImageComposeServiceImpl: ImageComposeService {
    func merge(base: Data, overlayPNG: Data) throws -> Data {
        guard
            let baseSource = CGImageSourceCreateWithData(base as CFData, nil),
            let baseCG     = CGImageSourceCreateImageAtIndex(baseSource, 0, nil),
            let overlaySource = CGImageSourceCreateWithData(overlayPNG as CFData, nil),
            let overlayCG     = CGImageSourceCreateImageAtIndex(overlaySource, 0, nil)
        else { throw ImageComposeError.decode }

        let width  = baseCG.width
        let height = baseCG.height
        guard
            let ctx = CGContext(
                data: nil,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
        else { throw ImageComposeError.render }

        ctx.draw(baseCG, in: CGRect(x: 0, y: 0, width: width, height: height))
        ctx.draw(overlayCG, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let outCG = ctx.makeImage() else { throw ImageComposeError.render }

        let out = CFDataCreateMutable(nil, 0)!
        guard let dst = CGImageDestinationCreateWithData(
            out, UTType.jpeg.identifier as CFString, 1, nil)
        else { throw ImageComposeError.encode }

        CGImageDestinationAddImage(dst, outCG, nil)
        guard CGImageDestinationFinalize(dst) else { throw ImageComposeError.encode }

        return out as Data
    }
}
