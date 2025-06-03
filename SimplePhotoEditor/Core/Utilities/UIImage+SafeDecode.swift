import UIKit
import CoreImage
import UniformTypeIdentifiers

/// Асинхронная (фоновая) декодировка `Data` → `UIImage`.
@MainActor
func safeDecodeImage(from rawData: Data?) async -> UIImage? {
    // 0. Пустые данные — сразу nil
    guard let data = rawData, !data.isEmpty else { return nil }


    return await Task.detached(priority: .userInitiated) {
        guard let ci = CIImage(data: data) else { return nil }
        let ctx = CIContext()
        guard let cg = ctx.createCGImage(ci, from: ci.extent) else { return nil }
        return UIImage(cgImage: cg)
    }.value
}
