import SwiftUI
import PhotosUI

struct EditorNavigationBar: ToolbarContent {
    @Binding var showSourceDialog: Bool
    let isShareEnabled: Bool
    // Новый колбэк: выбор формата через enum
    let onShareFormat: (ExportFormat) -> Void
    let onLogout: () -> Void

    // Локальный стейт для диалога, чтобы «привязать» к самой кнопке
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
            // Кнопка Share с привязанным confirmationDialog
            Button {
                showShareFormatDialog = true
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
            .disabled(!isShareEnabled)
            .labelStyle(.iconOnly)
            .confirmationDialog(
                String(localized: "Выберите формат"),
                isPresented: $showShareFormatDialog
            ) {
                Button("Поделиться как PNG") {
                    onShareFormat(.png)
                }
                Button("Поделиться как JPEG") {
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
