import SwiftUI
import PhotosUI

struct ImageSourceModifiers: ViewModifier {
    @Binding var showSourceDialog:  Bool
    @Binding var showLibraryPicker: Bool
    @Binding var showCameraPicker:  Bool
    @Binding var libraryItem: PhotosPickerItem?
    var vm: EditorViewModel

    func body(content: Content) -> some View {
        content
            .confirmationDialog("Источник изображения",
                                isPresented: $showSourceDialog) {
                Button("Камера")  { showCameraPicker  = true }
                Button("Галерея") { showLibraryPicker = true }
                Button("Отмена", role: .cancel) {}
            }
            .sheet(isPresented: $showCameraPicker) {
                CameraPicker { ui in
                    vm.inputData = ui.jpegData(compressionQuality: 1.0)
                }
            }
            .photosPicker(isPresented: $showLibraryPicker,
                          selection:    $libraryItem,
                          matching:     .images)
            .onChange(of: libraryItem) { _, new in
                Task {
                    if let item = new,
                       let data = try? await item.loadTransferable(type: Data.self) {
                        vm.inputData = data
                    }
                    libraryItem = nil
                }
            }
    }
}
