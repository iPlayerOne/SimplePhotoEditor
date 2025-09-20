import SwiftUI
import PencilKit

struct PencilCanvasView: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    var tool: PKInkingTool
    var isErasing: Bool
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.delegate      = context.coordinator
        canvas.drawingPolicy = .anyInput
        canvas.backgroundColor = .clear
        canvas.contentMode  = .redraw
        return canvas
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        if isErasing {
            if !(uiView.tool is PKEraserTool) {
                uiView.tool = PKEraserTool(.bitmap)
            }
        } else {
            if let ink = uiView.tool as? PKInkingTool {
                if ink.color != tool.color || ink.width != tool.width || ink.inkType != tool.inkType {
                    uiView.tool = tool
                }
            } else {
                uiView.tool = tool
            }
        }
        
        if uiView.drawing != drawing { uiView.drawing = drawing }
    }
    
    func makeCoordinator() -> Coordinator { Coordinator(self) }
    
    final class Coordinator: NSObject, PKCanvasViewDelegate {
        private let parent: PencilCanvasView
        init(_ parent: PencilCanvasView) { self.parent = parent }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing = canvasView.drawing
        }
    }
}
