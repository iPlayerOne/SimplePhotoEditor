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
