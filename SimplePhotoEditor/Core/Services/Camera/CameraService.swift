import AVFoundation
import UIKit

enum CameraGateResult { case granted, denied, unavailable }

protocol CameraAccess {
    func authorizeIfNeeded() async -> CameraGateResult
}

final class CameraAccessService: CameraAccess {
    func authorizeIfNeeded() async -> CameraGateResult {
        guard await UIImagePickerController.isSourceTypeAvailable(.camera) else {
            return .unavailable
        }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            return .granted
        case .notDetermined:
            let ok = await withCheckedContinuation { cont in
                AVCaptureDevice.requestAccess(for: .video) { cont.resume(returning: $0) }
            }
            return ok ? .granted : .denied
        case .denied, .restricted:
            return .denied
        @unknown default:
            return .denied
        }
    }
}
