import SwiftUI

struct SheetPrimaryGlassButtonStyle: ButtonStyle {
    var isCancel: Bool = false
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        let pressed   = configuration.isPressed && isEnabled
        let textTint  : Color = isCancel ? .white : .primary
        let bgTint    : Color = isCancel ? .red.opacity(0.22) : .clear   // ← красим фон
        let strokeTint: Color = isCancel
        ? .red.opacity(pressed ? 0.60 : 0.40)
        : .white.opacity(pressed ? 0.25 : 0.12)
        
        configuration.label
            .font(.title3.weight(.semibold))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: 60, alignment: .center)
            .contentShape(Capsule())
            .clipShape(Capsule())
        
        // фон капсулы (для Cancel — полупрозрачный красный)
            .background(Capsule().fill(bgTint))
        
        // стекло поверх формы
            .glassEffect(.regular.interactive(), in: Capsule())
        
        // обводка под роль
            .overlay(Capsule().stroke(strokeTint, lineWidth: 1))
        
        // цвет текста/символов
            .foregroundStyle(textTint)
            .tint(textTint)
        
            .opacity(isEnabled ? 1 : 0.6)
            .scaleEffect(pressed ? 0.98 : 1)
            .animation(.snappy(duration: 0.12), value: configuration.isPressed)
        
    }
}

extension ButtonStyle where Self == SheetPrimaryGlassButtonStyle {
    static func sheetPrimaryGlass(isCancel: Bool = false) -> SheetPrimaryGlassButtonStyle { .init(isCancel: isCancel) }
    static var sheetPrimaryGlassCancel: SheetPrimaryGlassButtonStyle { .init(isCancel: true) }
}
