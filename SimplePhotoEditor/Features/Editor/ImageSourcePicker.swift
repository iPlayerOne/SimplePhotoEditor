import SwiftUI
import PhotosUI

struct ImageSourcePicker: View {
    @Binding var showDialog: Bool
    @Binding var showCamera: Bool
    @Binding var showLibrary: Bool
    @Binding var libraryItem: PhotosPickerItem?
    let onImagePicked: (Data) -> Void

    var body: some View {
        // Пустой контейнер — все модификаторы навешиваем на него
        Color.clear
            .confirmationDialog("Источник изображения",
                                isPresented: $showDialog) {
                Button("Камера")  { showCamera = true }
                Button("Галерея") { showLibrary = true }
                Button("Отмена", role: .cancel) { }
            }
            .sheet(isPresented: $showCamera) {
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
    }
}
