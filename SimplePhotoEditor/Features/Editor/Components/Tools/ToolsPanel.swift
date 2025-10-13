import SwiftUI
import PencilKit

struct ToolsPanel: View {
    let mode: EditorMode
    let hasImage: Bool

    let filters: [Filter]
    @Binding var selectedFilter: Filter?
    @ObservedObject var cache: FilterPreviewCache

    @Binding var drawing: PKDrawing
    @Binding var tool: PKInkingTool
    @Binding var isErasing: Bool

    var panelHeight: CGFloat = 96

    private let verticalInset: CGFloat = 10

    private var innerPanelHeight: CGFloat {
        max(0, panelHeight - verticalInset * 2)
    }

    private var panelShape: some InsettableShape {
        Capsule()
    }

    var body: some View {
        content
            .padding(.vertical, verticalInset)
            .frame(maxWidth: .infinity)
            .frame(height: panelHeight)
            .clipShape(panelShape)
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: -2)
            .glassEffect()
    }

    @ViewBuilder
    private var content: some View {
        if mode == .draw {
            DrawToolsPanel(
                selectedTool: $tool,
                isErasing: $isErasing,
                drawing: $drawing
            )
            .frame(maxHeight: .infinity)
        } else if hasImage {
            FilterToolsPanel(
                filters: filters,
                selectedFilter: $selectedFilter,
                cache: cache,
                panelHeight: innerPanelHeight 
            )
        } else {
            Color.clear
        }
    }
}

#Preview("ToolsPanel — Draw (auto)", traits: .sizeThatFitsLayout) {
    @Previewable @State var selectedTool = PKInkingTool(.pen, color: .black, width: 5)
    @Previewable @State var isErasing = false
    @Previewable @State var drawing = PKDrawing()
    @Previewable @State var selectedFilter: Filter? = nil

    let cache = FilterPreviewCache()

    ToolsPanel(
        mode: .draw,
        hasImage: true,
        filters: [],
        selectedFilter: $selectedFilter,
        cache: cache,
        drawing: $drawing,
        tool: $selectedTool,
        isErasing: $isErasing,
        panelHeight: 96
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("ToolsPanel — Filters (auto)", traits: .sizeThatFitsLayout) {
    @Previewable var sampleFilters = [
        Filter(name: "Noir",    filterName: "CIPhotoEffectNoir"),
        Filter(name: "Chrome",  filterName: "CIPhotoEffectChrome"),
        Filter(name: "Fade",    filterName: "CIPhotoEffectFade"),
        Filter(name: "Instant", filterName: "CIPhotoEffectInstant"),
        Filter(name: "Process", filterName: "CIPhotoEffectProcess")
    ]
    @Previewable @State var selectedFilter: Filter? = nil
    @Previewable @State var drawing = PKDrawing()
    @Previewable @State var isErasing = false
    @Previewable @State var selectedTool = PKInkingTool(.pen, color: .black, width: 5)
    
    let cache = FilterPreviewCache()
    
    ToolsPanel(
        mode: .filters,
        hasImage: true,
        filters: sampleFilters,
        selectedFilter: $selectedFilter,
        cache: cache,
        drawing: $drawing,
        tool: $selectedTool,
        isErasing: $isErasing,
        panelHeight: 96
    )
    .onAppear {
        selectedFilter = sampleFilters.first
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("ToolsPanel — Empty (auto)", traits: .sizeThatFitsLayout) {
    @Previewable @State var selectedTool = PKInkingTool(.pen, color: .black, width: 5)
    @Previewable @State var isErasing = false
    @Previewable @State var drawing = PKDrawing()
    @Previewable @State var selectedFilter: Filter? = nil

    let cache = FilterPreviewCache()

    ToolsPanel(
        mode: .filters,
        hasImage: false,
        filters: [],
        selectedFilter: $selectedFilter,
        cache: cache,
        drawing: $drawing,
        tool: $selectedTool,
        isErasing: $isErasing,
        panelHeight: 96
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
