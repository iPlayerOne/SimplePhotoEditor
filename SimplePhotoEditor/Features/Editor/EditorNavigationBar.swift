import SwiftUI

struct EditorNavigationBar: ToolbarContent {
    @Binding var showSourceDialog: Bool
    
    let isShareEnabled: Bool
    let onShare: () -> Void
    let onLogout: () -> Void

    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button { showSourceDialog = true } label: {
                Image(systemName: "plus")
            }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(action: onShare) {
                Image(systemName: "square.and.arrow.up")
            }
            .disabled(!isShareEnabled)
        }
        ToolbarItem(placement: .navigationBarTrailing) {
            Button(role: .destructive, action: onLogout) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
            }
        }
    }
}
