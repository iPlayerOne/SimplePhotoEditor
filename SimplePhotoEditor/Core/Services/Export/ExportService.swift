import PhotosUI
import UIKit

enum ExportFormat {
    case jpeg
    case png
}

enum ExportError: Error {
    case permissionDenied
    case writeFailed
    case encodeFailed
}
protocol ExportService {
    func makeShareURL(from data: Data, format: ExportFormat) throws -> URL
    func saveToPhotos(_ data: Data) async throws
}



final class ExportServiceImpl: ExportService {
    func makeShareURL(from data: Data, format: ExportFormat = .jpeg) throws -> URL {
        switch format {
        case .jpeg:
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("jpg")

            guard (try? data.write(to: url, options: .atomic)) != nil else {
                throw ExportError.writeFailed
            }

            return url

        case .png:
            guard let ui = UIImage(data: data),
                  let pngData = ui.pngData()
            else {
                throw ExportError.encodeFailed
            }

            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("png")

            guard (try? pngData.write(to: url, options: .atomic)) != nil else {
                throw ExportError.writeFailed
            }

            return url
        }
    }

    func saveToPhotos(_ data: Data) async throws {
        guard try await requestAddOnlyPermission() else {
            throw ExportError.permissionDenied
        }
        
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetCreationRequest.forAsset()
                .addResource(with: .photo, data: data, options: nil)
        }
    }

    private func requestAddOnlyPermission() async throws -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        if status == .authorized { return true }
        let next = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        return next == .authorized
    }
}
