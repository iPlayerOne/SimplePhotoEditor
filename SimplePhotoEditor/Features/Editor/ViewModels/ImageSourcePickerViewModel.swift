import SwiftUI
import PhotosUI
import UIKit

@MainActor
final class ImageSourcePickerViewModel: ObservableObject {
    // Presentation flags
    @Published var isSheetPresented: Bool = false
    @Published var isCameraPresented: Bool = false
    @Published var isLibraryPresented: Bool = false
    @Published var showNoAccessAlert: Bool = false

    // PhotosPicker selection
    @Published var libraryItem: PhotosPickerItem?

    // Callback в EditorView
    private let onPicked: (Data) -> Void

    init(onPicked: @escaping (Data) -> Void) {
        self.onPicked = onPicked
    }

    // MARK: Sheet lifecycle
    func present() { isSheetPresented = true }
    func dismiss() { isSheetPresented = false }

    // MARK: Actions
    func onCameraTapped(cameraAccess: CameraAccess) {
        Task {
            switch await cameraAccess.authorizeIfNeeded() {
            case .granted:
                isSheetPresented = false
                isCameraPresented = true
            case .denied, .unavailable:
                isSheetPresented = false
                showNoAccessAlert = true
            }
        }
    }

    func onLibraryTapped() {
        isSheetPresented = false
        isLibraryPresented = true
    }

    func onCancel() {
        isSheetPresented = false
    }

    func handleCameraOutput(_ uiImage: UIImage?) {
        guard let ui = uiImage, let data = ui.jpegData(compressionQuality: 1.0) else { return }
        onPicked(data)
        isCameraPresented = false
    }

    func handleLibrarySelectionIfNeeded() {
        guard let item = libraryItem else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self) {
                onPicked(data)
            }
            libraryItem = nil
            isLibraryPresented = false
        }
    }

    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
