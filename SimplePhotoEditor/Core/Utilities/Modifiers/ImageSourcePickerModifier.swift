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
            .confirmationDialog("Источник изображения",
                                isPresented: $showDialog) {
                Button("Камера")  { openCamera() }
                Button("Галерея") { showLibrary = true }
                Button("Отмена", role: .cancel) { }
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
                                .alert("Нет доступа к камере",
                                       isPresented: $showPermissionAlert) {
                                    Button("Настройки") {
                                        if let url = URL(string: UIApplication.openSettingsURLString) {
                                            UIApplication.shared.open(url)
                                        }
                                    }
                                    Button("Отмена", role: .cancel) { }
                                } message: {
                                    Text("Разрешите доступ к камере в настройках устройства.")
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
