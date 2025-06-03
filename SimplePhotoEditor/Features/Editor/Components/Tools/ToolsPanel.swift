import SwiftUI
import PencilKit

struct ToolsPanel: View {
    @ObservedObject var vm: EditorViewModel
    @Binding var drawing: PKDrawing
    @Binding var tool: PKInkingTool
    @Binding var isErasing: Bool
    
    private let panelHeight: CGFloat = 76
    
    var body: some View {
        Group {
            if vm.markup == .draw {
                DrawToolsPanel(
                    selectedTool: $tool,
                    isErasing: $isErasing,
                    drawing: $drawing
                )
            } else {
                EmptyView()
            }
        }
        .frame(height: panelHeight)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
    }
}
