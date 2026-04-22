import SwiftUI

@inline(__always)
private func rotationFitScale(for frame: CGSize, quarterTurns: Int) -> CGFloat {
    guard quarterTurns % 2 != 0, frame.width > 0, frame.height > 0 else { return 1 }
    let r = frame.width / frame.height
    return min(r, 1 / r)
}

public extension View {
    func canvasTransform(
        quarterTurns: Int,
        flippedHorizontally: Bool,
        frameSize: CGSize
    ) -> some View {
        let angle = Double(quarterTurns) * 90.0
        let fit   = rotationFitScale(for: frameSize, quarterTurns: quarterTurns)

        return self
            .compositingGroup()
            .rotationEffect(.degrees(angle))
            .scaleEffect(x: (flippedHorizontally ? -1 : 1) * fit, y: fit, anchor: .center)
            .animation(.snappy(duration: 0.28, extraBounce: 0.0), value: quarterTurns)
            .animation(.snappy(duration: 0.28, extraBounce: 0.0), value: flippedHorizontally)
    }
}
