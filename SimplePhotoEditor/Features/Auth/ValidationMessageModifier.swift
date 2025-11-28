import SwiftUI
import UIKit

struct ValidationMessageModifier: ViewModifier {
    let message: String
    let visible: Bool
    let color: Color
    let spacing: CGFloat

    private var lineHeight: CGFloat {
        UIFont.preferredFont(forTextStyle: .footnote).lineHeight
    }

    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            content

            ZStack(alignment: .leading) {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(color)
                    .opacity(visible ? 1 : 0)
                    .accessibilityHidden(!visible)
                    .allowsHitTesting(false)
            }
            .frame(height: lineHeight)
        }
        .padding(.bottom, spacing)
        .animation(.default, value: visible)
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
