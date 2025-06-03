import PhotosUI

protocol ExportService {
    func makeShareURL(from data: Data) throws -> URL
    func saveToPhotos(_ data: Data) async throws
}

enum ExportError: Error {
    case permissionDenied
    case writeFailed
}

final class ExportServiceImpl: ExportService {

    func makeShareURL(from data: Data) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".jpg")
        do {
            try data.write(to: url, options: .atomic)
            return url
        } catch {
            throw ExportError.writeFailed
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
