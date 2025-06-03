import SwiftUI
import PencilKit

struct CanvasLayer: View {
    @Binding var drawing: PKDrawing
    let tool: PKInkingTool
    let isErasing: Bool
    let enabled: Bool

    var body: some View {
        PencilCanvasView(drawing: $drawing,
                         tool: tool,
                         isErasing: isErasing)
        .allowsHitTesting(enabled)
    }
}
