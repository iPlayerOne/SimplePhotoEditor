import SwiftUI
import PhotosUI
import UIKit

protocol ImageImportService {
    func dataFromCameraImage(_ image: UIImage?) -> Data?
    func loadData(from item: PhotosPickerItem) async throws -> Data?
}

final class ImageImportServiceImpl: ImageImportService {

    func dataFromCameraImage(_ image: UIImage?) -> Data? {
        guard let uiImage = image else { return nil }
        return uiImage.jpegData(compressionQuality: 0.95)
            ?? uiImage.pngData()
    }

    func loadData(from item: PhotosPickerItem) async throws -> Data? {
        if let data = try await item.loadTransferable(type: Data.self) {
            return data
        }

        if let url = try await item.loadTransferable(type: URL.self) {
            return try Data(contentsOf: url)
        }

        if let swiftUIImage = try await item.loadTransferable(type: Image.self) {
            return await MainActor.run {
                let renderer = ImageRenderer(content: swiftUIImage)
                renderer.scale = DisplayScale.fallback
                if let uiImage = renderer.uiImage {
                    return uiImage.jpegData(compressionQuality: 0.95)
                        ?? uiImage.pngData()
                }
                return nil
            }
        }

        return nil
    }
}
