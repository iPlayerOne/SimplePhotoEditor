import SwiftUI

struct AuthFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Color.secondary.opacity(0.3), lineWidth: 1)
            )
            .font(.body)
    }
}

extension View {
    func authFieldStyle() -> some View {
        modifier(AuthFieldModifier())
    }
}
