import SwiftUI

struct IconStyle: ViewModifier {
    let minSize: CGFloat
    let color: Color

    func body(content: Content) -> some View {
        content
            .font(.title3)
            .frame(minWidth: minSize, minHeight: minSize)
            .contentShape(Rectangle())
            .foregroundColor(color)
    }
}

extension View {
    func toolIcon(active: Bool, size: CGFloat = 44) -> some View {
        self.modifier(
            IconStyle(
                minSize: size,
                color:    active ? .accentColor : .secondary
            )
        )
    }

    func destructiveIcon(size: CGFloat = 44) -> some View {
        self.modifier(
            IconStyle(
                minSize: size,
                color:    .red
            )
        )
    }
}
