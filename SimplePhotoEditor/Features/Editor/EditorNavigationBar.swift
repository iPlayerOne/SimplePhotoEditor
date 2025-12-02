import SwiftUI
import PhotosUI

struct EditorNavigationBar: ToolbarContent {
    @Binding var showSourceDialog: Bool
    let isShareEnabled: Bool
    let onShareFormat: (ExportFormat) -> Void
    let onLogout: () -> Void
    @State private var showShareFormatDialog = false

    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button {
                showSourceDialog = true
            } label: {
                Image(systemName: "plus")
            }
            .labelStyle(.iconOnly)
        }

        ToolbarItemGroup(placement: .topBarTrailing) {
            Button {
                showShareFormatDialog = true
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
            .disabled(!isShareEnabled)
            .labelStyle(.iconOnly)
            .confirmationDialog(
                String(localized: "editor.export.format.title"),
                isPresented: $showShareFormatDialog
            ) {
                Button(String(localized: "editor.export.share.png")) {
                    onShareFormat(.png)
                }
                Button(String(localized: "editor.export.share.jpeg")) {
                    onShareFormat(.jpeg)
                }
                Button(String(localized: "common.cancel"), role: .cancel) { }
            }

            Button(role: .destructive, action: onLogout) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
            }
            .labelStyle(.iconOnly)
        }
    }
}
