//import SwiftUI
//
//struct CanvasTransform: ViewModifier {
//    let rotationQuarterTurns: Int
//    let isFlippedHorizontally: Bool
//    let animation: Animation = .easeInOut(duration: 0.3)
//
//    func body(content: Content) -> some View {
//        content
//            .rotationEffect(.degrees(Double(rotationQuarterTurns) * 90))
//            .scaleEffect(x: isFlippedHorizontally ? -1 : 1, y: 1)
//            .animation(animation, value: rotationQuarterTurns)
//            .animation(animation, value: isFlippedHorizontally)
//    }
//}
//
//extension View {
//    func canvasTransform(rotationCount: Int, flipped: Bool) -> some View {
//        modifier(CanvasTransform(rotationQuarterTurns: rotationCount,
//                                 isFlippedHorizontally: flipped))
//    }
//}
import SwiftUI

@inline(__always)
private func rotationFitScale(for frame: CGSize, quarterTurns: Int) -> CGFloat {
    guard quarterTurns % 2 != 0, frame.width > 0, frame.height > 0 else { return 1 }
    let r = frame.width / frame.height
    return min(r, 1 / r) // ≤ 1
}

public extension View {
    func canvasTransform(
        quarterTurns: Int,
        flippedHorizontally: Bool,
        frameSize: CGSize
    ) -> some View {
        let rot = Double(quarterTurns) * 90
        let fit = rotationFitScale(for: frameSize, quarterTurns: quarterTurns)

        return self
            .scaleEffect(fit)                                 // уместить при 90/270
            .scaleEffect(x: flippedHorizontally ? -1 : 1, y: 1) // флип
            .rotationEffect(.degrees(rot))                    // поворот
            .animation(.easeInOut(duration: 0.3), value: quarterTurns)
            .animation(.easeInOut(duration: 0.3), value: flippedHorizontally)
    }
}
