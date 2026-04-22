import SwiftUI
import Observation

@Observable
final class TextItem: Identifiable {
    let id = UUID()

    var text: String
    var font: FontOption
    var fontSize: Double
    var color: Color
    var position: CGPoint
    var isEditing: Bool

    var rotation: Double

    init(
        text: String,
        font: FontOption,
        fontSize: Double,
        color: Color,
        position: CGPoint,
        isEditing: Bool = false,
        rotation: Double = 0
    ) {
        self.text = text
        self.font = font
        self.fontSize = fontSize
        self.color = color
        self.position = position
        self.isEditing = isEditing
        self.rotation = rotation
    }
}
