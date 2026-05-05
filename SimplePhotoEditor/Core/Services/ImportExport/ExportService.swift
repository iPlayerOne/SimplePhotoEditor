import UIKit

enum ExportFormat {
    case jpeg
    case png
}

enum ExportError: Error {
    case writeFailed
    case encodeFailed
}
protocol ExportService {
    func makeShareURL(from data: Data, format: ExportFormat) throws -> URL
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

}
