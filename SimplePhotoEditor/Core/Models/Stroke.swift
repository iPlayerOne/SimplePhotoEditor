import SwiftUI

struct Stroke: Identifiable {
    let id: UUID = UUID()
    var points: [CGPoint]
    let lineWidth: CGFloat
    let color: Color
}
