import SwiftUI
import PencilKit

struct ToolsPanel: View {
//    @ObservedObject var vm: EditorViewModel
    let mode: EditorMode
    let hasImage: Bool
    
    let filters: [Filter]
    @Binding var selectedFilter: Filter?
    @ObservedObject var cache: FilterPreviewCache

    @Binding var drawing: PKDrawing
    @Binding var tool: PKInkingTool
    @Binding var isErasing: Bool
    
    private let panelHeight: CGFloat = 68
    
    var body: some View {
        Group {
            if  mode == .draw {
                DrawToolsPanel(
                    selectedTool: $tool,
                    isErasing: $isErasing,
                    drawing: $drawing
                )
            } else if hasImage {
                FilterToolsPanel(
                    filters: filters,
                    selectedFilter: $selectedFilter,
                    cache: cache
                )
            } else {
                Color.clear.frame(height: panelHeight)
            }
        }
        .frame(height: panelHeight)
        .frame(maxWidth: .infinity)
    }
}
