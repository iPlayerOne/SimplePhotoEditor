import UIKit
import Photos

enum ExportFormat {
    case jpeg
    case png
}

enum ExportError: Error {
    case writeFailed
    case encodeFailed
    case photoLibraryAccessDenied
}
protocol ExportService {
    func makeShareURL(from data: Data, format: ExportFormat) throws -> URL
    func saveToPhotoLibrary(data: Data) async throws
}



final class ExportServiceImpl: ExportService {
    func makeShareURL(from data: Data, format: ExportFormat = .jpeg) throws -> URL {
        switch format {
        case .jpeg:
            guard let ui = UIImage(data: data),
                  let jpegData = ui.jpegData(compressionQuality: 0.9)
            else {
                throw ExportError.encodeFailed
            }

            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("jpg")

            guard (try? jpegData.write(to: url, options: .atomic)) != nil else {
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

    func saveToPhotoLibrary(data: Data) async throws {
        guard UIImage(data: data) != nil else {
            throw ExportError.encodeFailed
        }

        let status = await requestPhotoLibraryAccessIfNeeded()
        guard status == .authorized || status == .limited else {
            throw ExportError.photoLibraryAccessDenied
        }

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetCreationRequest.forAsset()
                request.addResource(with: .photo, data: data, options: nil)
            } completionHandler: { success, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if success {
                    continuation.resume()
                } else {
                    continuation.resume(throwing: ExportError.writeFailed)
                }
            }
        }
    }

    private func requestPhotoLibraryAccessIfNeeded() async -> PHAuthorizationStatus {
        let current = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        guard current == .notDetermined else { return current }

        return await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                continuation.resume(returning: status)
            }
        }
    }

}
