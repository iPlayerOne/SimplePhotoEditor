import SwiftUI

struct TextItem: Identifiable {
    let id = UUID()

    var text:      String
    var fontName:  String
    var fontSize:  CGFloat
    var color:     Color
    var position:  CGPoint
    var parkedPosition: CGPoint?

    var isEditing  = false
}
