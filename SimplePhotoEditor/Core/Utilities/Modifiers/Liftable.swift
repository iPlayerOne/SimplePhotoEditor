import SwiftUI

struct Liftable: ViewModifier {
    @StateObject private var helper = KeyboardObserver()
    let isActive: Bool
    let centered: Bool
    private let padding: CGFloat = 8

    func body(content: Content) -> some View {
        GeometryReader { geo in

            let frame = geo.frame(in: .named("canvas"))
            let screen = UIScreen.main.bounds
            let kb     = helper.height

            let overlapY = max(
                0,
                frame.maxY - (screen.height - kb) + padding
            )

            let offsetX = centered ? (screen.midX - frame.midX) : 0

            content
                .offset(x: offsetX,
                        y: isActive ? -overlapY : 0)
                .animation(.easeOut(duration: 0.25), value: helper.height)
        }
    }
}

extension View {
    func liftable(if isActive: Bool, centered: Bool = false) -> some View {
        modifier(Liftable(isActive: isActive, centered: centered))
    }
}
