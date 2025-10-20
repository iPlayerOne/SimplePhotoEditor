import SwiftUI

@inline(__always)
private func rotationFitScale(for frame: CGSize, quarterTurns: Int) -> CGFloat {
    // При 90/270 градусов повернутый прямоугольник должен уместиться в исходный frame.
    guard quarterTurns % 2 != 0, frame.width > 0, frame.height > 0 else { return 1 }
    let r = frame.width / frame.height
    return min(r, 1 / r) // ≤ 1
}

public extension View {
    func canvasTransform(
        quarterTurns: Int,
        flippedHorizontally: Bool,
        frameSize: CGSize // фактический размер "неповёрнутой" канвы (из CanvasMetrics)
    ) -> some View {
        // Вращаем ПРОТИВ часовой при увеличении quarterTurns.
        // Если нужно по часовой — замените на минус.
        let angle = Double(quarterTurns) * 90.0
        let fit   = rotationFitScale(for: frameSize, quarterTurns: quarterTurns)

        return self
            // Сгруппировать подслои, чтобы GPU композитил их как единый слой
            .compositingGroup()
            // Ротация
            .rotationEffect(.degrees(angle))
            // Единый масштаб: учёт вписывания при 90/270 + горизонтальный флип
            .scaleEffect(x: (flippedHorizontally ? -1 : 1) * fit, y: fit, anchor: .center)
            // Одна «снэппи» анимация на оба состояния
            .animation(.snappy(duration: 0.28, extraBounce: 0.0), value: quarterTurns)
            .animation(.snappy(duration: 0.28, extraBounce: 0.0), value: flippedHorizontally)
            // Если сцена тяжёлая (много слоёв), можно добавить растрирование на GPU:
            // .drawingGroup() // включайте только если реально видите профит
    }
}
