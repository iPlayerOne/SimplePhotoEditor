import SwiftUI
import PhotosUI

struct EditorNavigationBar: ToolbarContent {
    @Binding var showSourceDialog: Bool
    let isShareEnabled: Bool
    let onShare: () -> Void
    let onLogout: () -> Void

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
            Button(action: onShare) {
                Image(systemName: "square.and.arrow.up")
            }
            .disabled(!isShareEnabled)
            .labelStyle(.iconOnly)

            Button(role: .destructive, action: onLogout) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
            }
            .labelStyle(.iconOnly)
        }
    }
}
