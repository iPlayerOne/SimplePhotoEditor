import SwiftUI

struct Draggable: ViewModifier {
    @State private var accumulated: CGSize = .zero
    @GestureState private var dragOffset: CGSize = .zero

    let enabled: Bool
    let coordinateSpace: CoordinateSpace

    func body(content: Content) -> some View {
        content
            .offset(
                x: accumulated.width + (enabled ? dragOffset.width : 0),
                y: accumulated.height + (enabled ? dragOffset.height : 0)
            )
            .gesture(
                enabled
                    ? DragGesture(minimumDistance: 10, coordinateSpace: coordinateSpace)
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation
                        }
                        .onEnded { value in
                            accumulated.width  += value.translation.width
                            accumulated.height += value.translation.height
                        }
                    : nil
            )
    }
}

extension View {
    func draggable(
        enabled: Bool,
        coordinateSpace: CoordinateSpace = .local
    ) -> some View {
        modifier(Draggable(enabled: enabled,
                           coordinateSpace: coordinateSpace))
    }
}
