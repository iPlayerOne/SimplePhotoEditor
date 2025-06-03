//
//  ImageComposeService.swift
//  SimplePhotoEditor
//
//  Created by ikorobov on 1. 5. 2025..
//


// Services/ImageComposeService.swift
import Foundation
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers

protocol ImageComposeService {
    /// Накладывает PNG-слой поверх base-изображения.
    func merge(base: Data, overlayPNG: Data) throws -> Data
}

enum ImageComposeError: Error { case decode, render, encode }

final class ImageComposeServiceImpl: ImageComposeService {
    func merge(base: Data, overlayPNG: Data) throws -> Data {
        // === Декодируем оба слоя в CGImage ===
        guard
            let srcProvider = CGDataProvider(data: base as CFData),
            let baseCG      = CGImage(jpegDataProviderSource: srcProvider,
                                      decode: nil, shouldInterpolate: true, intent: .defaultIntent),
            let overlayProvider = CGDataProvider(data: overlayPNG as CFData),
            let overlayCG      = CGImage(pngDataProviderSource: overlayProvider,
                                         decode: nil, shouldInterpolate: true, intent: .defaultIntent)
        else { throw ImageComposeError.decode }

        // === Рендерим в bitmap-context той же размерности ===
        let width  = baseCG.width
        let height = baseCG.height
        guard
            let ctx = CGContext(data: nil,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: width * 4,
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        else { throw ImageComposeError.render }

        ctx.draw(baseCG, in: CGRect(x: 0, y: 0, width: width, height: height))
        ctx.draw(overlayCG, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let outCG = ctx.makeImage() else { throw ImageComposeError.render }

        // === Кодируем в JPEG ===
        let out = CFDataCreateMutable(nil, 0)!
        guard let dst = CGImageDestinationCreateWithData(
            out, UTType.jpeg.identifier as CFString, 1, nil)
        else { throw ImageComposeError.encode }

        CGImageDestinationAddImage(dst, outCG, nil)
        guard CGImageDestinationFinalize(dst) else { throw ImageComposeError.encode }

        return out as Data
    }
}