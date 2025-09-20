# Image Processing and Core Image – Code Map

This document aggregates all relevant code paths for image processing and Core Image usage in SimplePhotoEditor, including every spot where a 1px seam could appear.

## Files Included
- Core/Services/Processing: `CIContextPool.swift`, `CIHelpers.swift`, `FilterService.swift`, `PreviewRenderService.swift`, `TransformService.swift`, `ImageDecodeService.swift`, `ImagePipeline.swift`
- Editor components using CI: `FilterPreviewCache.swift`, `FilteredImageView.swift`
- Utilities affecting decoding and pixel snapping: `UIImage+SafeDecode.swift`, `PixelSnap.swift`

---

## Core/Services/Processing/CIContextPool.swift
```swift
import CoreImage

enum CIContextPool {
    static let shared: CIContext = {
        let opts: [CIContextOption: Any] = [.priorityRequestLow: true]
        return CIContext(options: opts)
    }()
}
```

## Core/Services/Processing/CIHelpers.swift
```swift
import CoreImage

enum CIHelpers {
    static func lanczosScaled(_ ci: CIImage, scale: CGFloat) -> CIImage {
        guard scale < 0.999,
              let f = CIFilter(name: "CILanczosScaleTransform")
        else { return ci }
        
        let input = ci.clampedToExtent()
        f.setValue(input, forKey: kCIInputImageKey)
        f.setValue(scale, forKey: kCIInputScaleKey)
        f.setValue(1.0,   forKey: kCIInputAspectRatioKey)
        let out = f.outputImage ?? ci
        
        let scaledRect = ci.extent.applying(CGAffineTransform(scaleX: scale, y: scale))
        return out.cropped(to: scaledRect)
    }
}

extension CIImage {
    func snappedForDisplay() -> CIImage {
        let r = self.extent.integral
        let snapped = CGRect(
            x: floor(r.origin.x),
            y: floor(r.origin.y),
            width: round(r.size.width),
            height: round(r.size.height)
        )
        if snapped == r {
            return self.cropped(to: snapped)
        }
        return self
            .transformed(by: CGAffineTransform(translationX: -snapped.origin.x,
                                               y: -snapped.origin.y))
            .cropped(to: CGRect(origin: .zero, size: snapped.size))
    }
}
```

## Core/Services/Processing/FilterService.swift
```swift
import UIKit
import CoreImage

protocol FilterService {
    func apply(filterName: String, to data: Data, downscaleFactor: CGFloat) throws -> Data
}

enum FilterError: Error { case invalidData, renderFailed }

final class FilterServiceImpl: FilterService {
    
    func apply(filterName: String, to data: Data, downscaleFactor: CGFloat = 1.0) throws -> Data {
        guard var ci = CIImage(data: data, options: [.applyOrientationProperty: true]) else {
            throw FilterError.invalidData
        }

        ci = CIHelpers.lanczosScaled(ci, scale: downscaleFactor)
        let srcExtent = ci.extent
        var out = ci.clampedToExtent()

        if !filterName.isEmpty, let fx = CIFilter(name: filterName) {
            fx.setValue(out, forKey: kCIInputImageKey)
            out = fx.outputImage ?? out
        }

        out = out.cropped(to: srcExtent).snappedForDisplay()
        let bg = ci.clampedToExtent().cropped(to: srcExtent).snappedForDisplay()
        out = out.composited(over: bg)

        let rect = out.extent.integral
        guard let cg = CIContextPool.shared.createCGImage(out, from: rect) else {
            throw FilterError.renderFailed
        }
        guard let jpeg = UIImage(cgImage: cg, scale: 1, orientation: .up)
            .jpegData(compressionQuality: 0.9) else {
            throw FilterError.renderFailed
        }
        return jpeg
    }
}
```

## Core/Services/Processing/PreviewRenderService.swift
```swift
import UIKit
import CoreImage

protocol PreviewRenderService {
  func renderPreview(
    data:            Data,
    filterName:      String?,
    downscaleFactor: Double
  ) throws -> UIImage
}

final class PreviewRenderServiceImpl: PreviewRenderService {
  private let queue = DispatchQueue(
    label: "SimplePhotoEditor.Preview",
    qos:   .userInitiated
  )

  func renderPreview( data: Data, filterName: String?, downscaleFactor: Double ) throws -> UIImage {
    try queue.sync {
      guard var ci = CIImage(data: data, options: [.applyOrientationProperty: true]) else {
        throw NSError(domain: "PreviewRender", code: -10)
      }

      ci = CIHelpers.lanczosScaled(ci, scale: CGFloat(downscaleFactor))
      let srcExtent = ci.extent
      var out = ci.clampedToExtent()

      if let name = filterName, !name.isEmpty, let fx = CIFilter(name: name) {
        fx.setValue(out, forKey: kCIInputImageKey)
        out = fx.outputImage ?? out
      }

      out = out.cropped(to: srcExtent).snappedForDisplay()
      let bg = ci.clampedToExtent().cropped(to: srcExtent).snappedForDisplay()
      out = out.composited(over: bg)

      let rect = out.extent.integral
      guard let cg = CIContextPool.shared.createCGImage(out, from: rect) else {
        throw NSError(domain: "PreviewRender", code: -1)
      }
      return UIImage(cgImage: cg, scale: 1, orientation: .up)
    }
  }
}
```

## Core/Services/Processing/TransformService.swift
```swift
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
    private let ctx = CIContextPool.shared

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
```

## Core/Services/Processing/ImageDecodeService.swift
```swift
import UIKit
import ImageIO

protocol ImageDecodeService {
    func decodeFull(_ data: Data)-> UIImage?
    func downsample(_ data: Data, maxDimension: CGFloat, _ scale: CGFloat)-> UIImage?
}

final class ImageDecodeServiceImpl: ImageDecodeService {
    func decodeFull(_ data: Data) -> UIImage? {
        guard let src = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        guard let cg = CGImageSourceCreateImageAtIndex(src, 0, nil) else {
            return nil
        }
        return UIImage(cgImage: cg, scale: UIScreen.main.scale, orientation: .up)
    }
    
    func downsample(_ data: Data, maxDimension: CGFloat, _ scale: CGFloat) -> UIImage? {
        let srcOpts: CFDictionary = [ kCGImageSourceShouldCache: false] as CFDictionary
        let maxPixel = maxDimension * scale
        guard let src = CGImageSourceCreateWithData(data as CFData, srcOpts) else {
            return nil
        }
        let downscaleOpts: CFDictionary = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixel
        ] as CFDictionary
        guard let cg = CGImageSourceCreateThumbnailAtIndex(src, 0, downscaleOpts) else {
            return nil
        }
        return UIImage(cgImage: cg, scale: scale, orientation: .up)
    }
}
```

## Core/Services/Processing/ImagePipeline.swift
```swift
import UIKit
import PencilKit

protocol ImagePipeline {
    func makePreview(from data: Data, filterName: String?, downscaleFactor: CGFloat) async -> UIImage?
    func makeFinalImage(
        from data: Data,
        filterName: String?,
        rotation: Int,
        isFlipped: Bool,
        drawing: PKDrawing?,
        texts: [TextItem]?,
        canvasSize: CGSize,
        imageSize: CGSize
    ) async throws -> Data
}

final class ImagePipelineImpl: ImagePipeline {
    private let decode: ImageDecodeService
    private let transform: TransformService
    private let filter: FilterService
    private let overlay: OverlayRenderService

    init(decode: ImageDecodeService, transform: TransformService, filter: FilterService, overlay: OverlayRenderService) {
        self.decode = decode
        self.transform = transform
        self.filter = filter
        self.overlay = overlay
    }

    func makePreview(from data: Data, filterName: String?, downscaleFactor: CGFloat) async -> UIImage? {
        let decode = self.decode
        let filter = self.filter

        return await Task.detached(priority: .userInitiated) {
            guard let preview = await decode.downsample(data, maxDimension: 600, UIScreen.main.scale) else {
                return nil
            }
            guard let name = filterName, !name.isEmpty else {
                return preview
            }
            guard
                let jpeg = preview.jpegData(compressionQuality: 0.9),
                let filteredData = try? filter.apply(filterName: name, to: jpeg, downscaleFactor: downscaleFactor),
                let filteredPreview = UIImage(data: filteredData)
            else {
                return preview
            }
            return filteredPreview
        }.value
    }

    func makeFinalImage(
        from data: Data,
        filterName: String?,
        rotation: Int,
        isFlipped: Bool,
        drawing: PKDrawing?,
        texts: [TextItem]?,
        canvasSize: CGSize,
        imageSize: CGSize
    ) async throws -> Data {
        let transform = self.transform
        let filter = self.filter
        let overlay = self.overlay

        return try await Task.detached(priority: .userInitiated) {
            var out = data

            if rotation != 0 {
                out = try transform.rotate90(data: out, times: rotation)
            }
            if isFlipped {
                out = try transform.flipHorizontal(data: out)
            }

            if let name = filterName, !name.isEmpty {
                out = try filter.apply(filterName: name, to: out, downscaleFactor: 1.0)
            }

            let hasTexts = !(texts?.isEmpty ?? true)
            if drawing != nil || hasTexts {
                out = try overlay.apply(
                    drawing: drawing,
                    texts: texts,
                    to: out,
                    canvasSize: canvasSize,
                    imageSize: imageSize
                )
            }

            return out
        }.value
    }
}
```

## Features/Editor/Components/FilterTools/FilterPreviewCache.swift
```swift
import UIKit
import Combine

final class FilterPreviewCache: ObservableObject {
    @Published private(set) var previews: [UUID: UIImage] = [:]
    
    private var generation = UUID()
    private var worker: Task<Void, Never>?
    
    private let previewMaxSide: CGFloat = 180
    
    func preparePreviews(for image: UIImage?, filters: [Filter]) {
        worker?.cancel()
        
        let gen = UUID()
        generation = gen
        
        guard let image = image else { return }
        
        let jobs = filters.map { (id: $0.id, name: $0.filterName) }
        let src = image
        
        let maxSide = max(src.size.width, src.size.height)
        let scale: CGFloat = maxSide > previewMaxSide ? (previewMaxSide / maxSide ) : 1
        
        worker = Task.detached(priority: .userInitiated) { [gen, jobs, src, scale] in
            var out: [UUID: UIImage] = [:]
            
            for (id, name) in jobs {
                if Task.isCancelled { return }
                if let ui = Self.apply(name, to: src, scale: scale) {
                    out[id] = ui
                }
            }
            
            let result = out
            
            await MainActor.run { [weak self] in
                guard let self,gen == self.generation else { return }
                self.previews = result
            }
        }
    }
    
    private static func apply(_ filterName: String, to image: UIImage, scale: CGFloat) -> UIImage? {
        guard var ci = CIImage(image: image, options: [.applyOrientationProperty: true]) else { return image }
        ci = CIHelpers.lanczosScaled(ci, scale: scale)
        let srcExtent = ci.extent
        var out = ci.clampedToExtent()

        if !filterName.isEmpty, let fx = CIFilter(name: filterName) {
            fx.setValue(out, forKey: kCIInputImageKey)
            out = fx.outputImage ?? out
        }

        out = out.cropped(to: srcExtent).snappedForDisplay()
        let bg = ci.clampedToExtent().cropped(to: srcExtent).snappedForDisplay()
        out = out.composited(over: bg)

        guard let cg = CIContextPool.shared.createCGImage(out, from: out.extent) else {
            return image
        }
        return UIImage(cgImage: cg, scale: image.scale, orientation: .up)
    }
}
```

## Features/Editor/Components/FilterTools/FilteredImageView.swift
```swift
import UIKit
import SwiftUI

struct FilteredImageView: UIViewRepresentable {
    let baseImage: UIImage
    let filterName: String

    func makeUIView(context: Context) -> UIImageView {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        context.coordinator.task?.cancel()

        let input = baseImage
        let name  = filterName

        context.coordinator.task = Task {
            let output = await Self.renderFiltered(baseImage: input, filterName: name)
            guard !Task.isCancelled else { return }
            await MainActor.run { uiView.image = output }
        }
    }

    final class Coordinator {
        var task: Task<Void, Never>?
        deinit { task?.cancel() }
    }

    private static func renderFiltered(baseImage: UIImage, filterName: String) async -> UIImage {
        if filterName.isEmpty { return baseImage }

        return await Task.detached(priority: .userInitiated) { () -> UIImage in
            autoreleasepool {
                guard var ci = CIImage(image: baseImage, options: [.applyOrientationProperty: true]) else {
                    return baseImage
                }

                let srcExtent = ci.extent
                var out = ci.clampedToExtent()
                if let fx = CIFilter(name: filterName) {
                    fx.setValue(out, forKey: kCIInputImageKey)
                    out = fx.outputImage ?? out
                }
                out = out.cropped(to: srcExtent).snappedForDisplay()
                let bg = ci.clampedToExtent().cropped(to: srcExtent).snappedForDisplay()
                out = out.composited(over: bg)

                let ctx = CIContextPool.shared
                guard let cg = ctx.createCGImage(out, from: out.extent) else {
                    return baseImage
                }
                return UIImage(cgImage: cg, scale: baseImage.scale, orientation: .up)
            }
        }.value
    }
}
```

## Core/Utilities/UIImage+SafeDecode.swift
```swift
import UIKit
import CoreImage
import UniformTypeIdentifiers

@MainActor
func safeDecodeImage(from rawData: Data?) async -> UIImage? {
    guard let data = rawData, !data.isEmpty else { return nil }

    return await Task.detached(priority: .userInitiated) {
        guard let ci = CIImage(data: data) else { return nil }
        let snapped = ci.snappedForDisplay()
        let ctx = CIContextPool.shared
        guard let cg = ctx.createCGImage(snapped, from: ci.extent) else { return nil }
        return UIImage(cgImage: cg)
    }.value
}
```

## Core/Utilities/PixelSnap.swift
```swift
import UIKit
import SwiftUI

@inline(__always)
func snapToPixel(_ v: CGFloat, scale: CGFloat = UIScreen.main.scale) -> CGFloat {
    (v * scale).rounded() / scale
}

extension View {
    func hideHorizontalSeam() -> some View {
        let eps = 1 / UIScreen.main.scale
        return self.padding(.horizontal, -eps / 2)
    }
}
```

---

This captures every CI entry/exit point and related rendering paths where edge artifacts can surface.

