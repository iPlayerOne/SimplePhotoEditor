import SwiftUI

struct UnderlineModifier: ViewModifier {
    let isSelected: Bool
    let widthFraction: CGFloat
    let color: Color
    let height: CGFloat
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { proxy in
                    Rectangle()
                        .fill(color)
                        .frame(
                            width: proxy.size.width * widthFraction,
                            height: height
                        )
                        .offset(
                            x: (proxy.size.width - proxy.size.width * widthFraction) / 2,
                            y: proxy.size.height - height/2
                        )
                        .opacity(isSelected ? 1 : 0)
                }
            )
    }
}

extension View {
    func underline(selected: Bool,
                   color: Color = .accentColor,
                   widthFraction: CGFloat = 1,
                   height: CGFloat = 2
    ) -> some View {
        modifier(
            UnderlineModifier(
                isSelected: selected,
                widthFraction: widthFraction,
                color: color,
                height: height
            )
        )
    }
}
