//import AVFoundation
//
//final class CameraService: NSObject, ObservableObject {
//    private let session: AVCaptureSession = AVCaptureSession()
//    @Published var isRunning: Bool = false
//    @Published var authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
//    
//    func requestPermissionIfNeeded(completion: @escaping (Bool) -> Void) {
//        switch authorizationStatus {
//            case .notDetermined:
//                AVCaptureDevice.requestAccess(for: .video) { granted in
//                    DispatchQueue.main.async {
//                        self.authorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
//                        completion(granted)
//                    }
//                }
//            case .authorized:
//                completion(true)
//            default:
//                completion(false)
//        }
//    }
//    
//    func startSession() {
//        guard authorizationStatus == .authorized else { return }
//        
//        if session.inputs.isEmpty {
//            if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
//               let input = try? AVCaptureDeviceInput(device: device),
//               session.canAddInput(input) {
//                session.addInput(input)
//            }
//        }
//        session.startRunning()
//        isRunning = true
//    }
//    
//    func stopSession() {
//        session.stopRunning()
//        isRunning = false
//    }
//}
