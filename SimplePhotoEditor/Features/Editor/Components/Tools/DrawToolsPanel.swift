import SwiftUI
import PencilKit

struct DrawToolsPanel: View {
    @Binding var selectedTool: PKInkingTool
    @Binding var isErasing: Bool
    @Binding var drawing: PKDrawing

    @State private var widthUI: Double = 5

    var body: some View {
        HStack(spacing: 16) {
            Button { isErasing = false } label: {
                Image(systemName: "pencil.tip")
            }
            .toolIcon(active: !isErasing)

            Button { isErasing = true } label: {
                Image(systemName: "eraser")
            }
            .toolIcon(active: isErasing)

            ColorPicker("", selection: Binding(
                get: { Color(selectedTool.color) },
                set: { newColor in
                    selectedTool = PKInkingTool(
                        selectedTool.inkType,
                        color: UIColor(newColor),
                        width: selectedTool.width
                    )
                }
            ))
            .labelsHidden()
            .frame(width: 44, height: 44)

            Slider(
                value: $widthUI,
                in: 1...30,
                step: 1
            )
            .frame(maxWidth: 160)
            .onAppear {
                widthUI = Double(selectedTool.width)
            }
            .onChange(of: widthUI) { _, newValue in
                let newWidth = CGFloat(newValue)
                if abs(selectedTool.width - newWidth) > 0.001 {
                    selectedTool = PKInkingTool(
                        selectedTool.inkType,
                        color: selectedTool.color,
                        width: newWidth
                    )
                }
            }

            Spacer()

            // Очистка холста
            Button(role: .destructive) {
                drawing = PKDrawing()
            } label: {
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
