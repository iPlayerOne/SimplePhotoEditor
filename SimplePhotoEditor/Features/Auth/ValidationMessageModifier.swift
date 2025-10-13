import SwiftUI
import UIKit

struct ValidationMessageModifier: ViewModifier {
    let message: String
    let visible: Bool
    let color: Color
    let spacing: CGFloat

    // Учитываем Dynamic Type
    private var lineHeight: CGFloat {
        UIFont.preferredFont(forTextStyle: .footnote).lineHeight
    }

    func body(content: Content) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            // Само поле
            content

            // Полоса под подсказку фиксированной высоты
            ZStack(alignment: .leading) {
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(color)      // красный по умолчанию
                    .opacity(visible ? 1 : 0)
                    .accessibilityHidden(!visible)
                    .allowsHitTesting(false)
            }
            .frame(height: lineHeight) // резервируем место всегда
        }
        // Небольшой зазор до следующего элемента
        .padding(.bottom, spacing)
        .animation(.default, value: visible)
    }
}

extension View {
    // color — настраиваемый, по умолчанию .red
    func validationMessage(
        _ message: String,
        visible: Bool,
        color: Color = .red,
        spacing: CGFloat = 4
    ) -> some View {
        modifier(ValidationMessageModifier(message: message, visible: visible, color: color, spacing: spacing))
    }
}
