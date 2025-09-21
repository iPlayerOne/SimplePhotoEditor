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

    init(
        text: String,
        font: FontOption,
        fontSize: Double,
        color: Color,
        position: CGPoint,
        isEditing: Bool = false
    ) {
        self.text = text
        self.font = font
        self.fontSize = fontSize
        self.color = color
        self.position = position
        self.isEditing = isEditing
    }
}
