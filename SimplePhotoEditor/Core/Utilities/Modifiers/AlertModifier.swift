import SwiftUI

struct AlertModifier<E>: ViewModifier where E: LocalizedError & Identifiable {
    let title: String
    @Binding var error: E?

    func body(content: Content) -> some View {
        content
            .alert(item: $error) { err in
                Alert(
                    title: Text(title),
                    message: Text(err.errorDescription ?? ""),
                    dismissButton: .cancel(Text("OK"))
                )
            }
    }
}

extension View {
    func alertLocalizedError<E>(_ error: Binding<E?>, title: String = "Error") -> some View where E: LocalizedError & Identifiable {
        self.modifier(AlertModifier(title: title, error: error))
    }
}
