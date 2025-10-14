import SwiftUI
import PhotosUI

struct ImageSourcePicker: View {
    @Binding var showDialog: Bool
    @Binding var showCamera: Bool
    @Binding var showLibrary: Bool
    @Binding var libraryItem: PhotosPickerItem?
    let onImagePicked: (Data) -> Void
    
    @State private var showPermissionAlert: Bool = false
    
    var body: some View {
        Color.clear
            .confirmationDialog(String(localized: "editor.source.title"),
                                isPresented: $showDialog) {
                Button(String(localized: "editor.camera"))  { openCamera() }
                Button(String(localized: "editor.gallery")) { showLibrary = true }
                Button(String(localized: "common.cancel"), role: .cancel) { }
            }
                                .fullScreenCover(isPresented: $showCamera) {
                                    CameraPicker { uiImage in
                                        if let data = uiImage.jpegData(compressionQuality: 1.0) {
                                            onImagePicked(data)
                                        }
                                        showCamera = false
                                    }
                                    .ignoresSafeArea()
                                }
                                .photosPicker(isPresented: $showLibrary,
                                              selection:    $libraryItem,
                                              matching:     .images,
                                              photoLibrary: .shared())
                                .onChange(of: libraryItem) { oldItem, newItem in
                                    guard let item = newItem else { return }
                                    Task {
                                        if let data = try? await item.loadTransferable(type: Data.self) {
                                            onImagePicked(data)
                                        }
                                        libraryItem = nil
                                        showLibrary = false
                                    }
                                }
                                .alert(String(localized: "editor.no_access_camera.title"),
                                       isPresented: $showPermissionAlert) {
                                    Button(String(localized: "common.settings")) {
                                        if let url = URL(string: UIApplication.openSettingsURLString) {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                    Button(String(localized: "common.cancel"), role: .cancel) { }
                                } message: {
                                    Text(String(localized: "editor.no_access_camera.message"))
                                }
    }
    
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            showPermissionAlert = true
            return
        }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                showCamera = true
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        DispatchQueue.main.async {
                            granted ? (showCamera = true) : (showPermissionAlert = true)
                        }
                    }
                }
            case .denied, .restricted:
                showPermissionAlert = true
            default: break
        }
    }
}
