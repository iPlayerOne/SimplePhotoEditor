import SwiftUI
import PencilKit

struct DrawToolsPanel: View {
    @Binding var selectedTool: PKInkingTool
    @Binding var isErasing: Bool
    @Binding var drawing: PKDrawing

    var body: some View {
        HStack(spacing: 16) {
            Button { isErasing = false } label: { Image(systemName: "pencil.tip") }
                .toolIcon(active: !isErasing)
            Button { isErasing = true }  label: { Image(systemName: "eraser") }
                .toolIcon(active: isErasing)
            
            ColorPicker("", selection: Binding(
                get: { Color(selectedTool.color) },
                set: { selectedTool = PKInkingTool(selectedTool.inkType,
                                                   color: UIColor($0),
                                                   width: selectedTool.width) }
            ))
            .labelsHidden()
            .frame(width: 44, height: 44)

            Slider(value: Binding(
                get: { Double(selectedTool.width) },
                set: { selectedTool = PKInkingTool(selectedTool.inkType,
                                                   color: selectedTool.color,
                                                   width: CGFloat($0)) }
            ), in: 1...30)
            .frame(maxWidth: 120)

            Spacer()

            Button(role: .destructive) { drawing = PKDrawing() } label: {
                Image(systemName: "trash")
            }
            .destructiveIcon()
        }
        .padding(.horizontal, 16)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @State var selectedTool = PKInkingTool(.pen, color: .black, width: 5)
    @Previewable @State var isErasing = false
    @Previewable @State var drawing = PKDrawing()
    DrawToolsPanel(
        selectedTool: $selectedTool,
        isErasing:    $isErasing,
        drawing:      $drawing
    )
    .padding()
}
