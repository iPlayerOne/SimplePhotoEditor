import SwiftUI

struct ValidationMessageModifier: ViewModifier {
    let message: String
    let visible: Bool
    let color: Color
    let spacing: CGFloat

    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: spacing) {
            content

            Text(message)
                .font(.footnote)
                .foregroundStyle(color)
                .opacity(visible ? 1 : 0)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: 18) // фиксированная высота под сообщение
        }
    }
}

extension View {
    func validationMessage(
        _ message: String,
        visible: Bool,
        color: Color = .red,
        spacing: CGFloat = 4
    ) -> some View {
        modifier(ValidationMessageModifier(message: message, visible: visible, color: color, spacing: spacing))
    }
}
