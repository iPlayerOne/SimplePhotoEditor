import SwiftUI

struct ShimmerModifier: ViewModifier {
    @State private var offset: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geo in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.clear,
                                    Color.white.opacity(0.7),
                                    Color.clear
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .rotationEffect(.degrees(20))
                        .frame(width: geo.size.width * 1.5, height: geo.size.height)
                        .offset(x: geo.size.width * offset)
                        .animation(
                            Animation.linear(duration: 0.9)
                                .repeatForever(autoreverses: false),
                            value: offset
                        )
                }
            )
            .onAppear {
                offset = 1.2
            }
    }
}

extension View {
    func shimmer() -> some View {
        self.modifier(ShimmerModifier())
    }
} 