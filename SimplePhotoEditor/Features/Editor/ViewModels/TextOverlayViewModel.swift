import SwiftUI
import Combine

fileprivate struct CanvasFrame {
    let canvas: CGSize
    let minY: CGFloat
    let maxY: CGFloat
    
    init(canvas: CGSize, keyboard: CGFloat, imageSize: CGSize?, textH: CGFloat = 44, margin: CGFloat = 8 ) {
        let imgW = imageSize?.width  ?? canvas.width
        let imgH = imageSize?.height ?? canvas.height
        
        let dispH = imgW / imgH > canvas.width / canvas.height
        ? canvas.width  / (imgW / imgH)
        : canvas.height
        
        let vInset = (canvas.height - dispH) / 2
        minY = vInset + textH/2 + margin
        maxY = canvas.height - vInset - textH/2 - margin - keyboard
        self.canvas = canvas
    }
    
}

@MainActor
final class TextOverlayViewModel: ObservableObject {
    
    @Published var items: [TextItem] = []
    @Published var activeID: UUID?
    @Published var isPlacing  = false
    
    @Published var currentColor: Color   = .white {
        didSet { apply(.color(currentColor)) }
    }
    
    @Published var currentSize:  CGFloat = 24 {
        didSet { apply(.size(currentSize)) }
    }
    
    private var waitForKeyboard: Bool = false
    
    func enterPlacement() {
        isPlacing = true
        activeID  = nil
        waitForKeyboard = true
    }
    
    
    func placeText(in canvas: CGSize, keyboardH: CGFloat, imageSize: CGSize?) {
        let frame = CanvasFrame(canvas: canvas, keyboard: keyboardH, imageSize: imageSize)
        let y = (frame.minY + frame.maxY) / 2
        let p = CGPoint(x: canvas.width / 2, y: y)
        
        let item = TextItem(text: "Текст",
                            fontName: "System",
                            fontSize: currentSize,
                            color: currentColor,
                            position: p,
                            isEditing: true
        )
        items.append(item)
        activeID = item.id
        isPlacing = false
        waitForKeyboard = false
        
    }
    
    func setActive(id: UUID, editing: Bool = false) {
        print("🔤 setActive(id: \(id), editing: \(editing))")
        activeID = id
        isPlacing = false
        if editing { mutateActive { $0.isEditing = true } }
    }
    
    func finishEditing() {
        print("🔤 finishEditing() — до: activeID=\(String(describing: activeID)), items=\(items.map { "\($0.id):\($0.isEditing)" })")
        mutateActive { $0.isEditing = false}
        activeID = nil
        isPlacing = true
        print("🔤 finishEditing() — после: activeID=\(String(describing: activeID)), items=\(items.map { "\($0.id):\($0.isEditing)" })")
    }
    
    func apply(_ edit: Edit) {
        mutateActive {
            switch edit {
                case .size(let s): $0.fontSize = s
                case .color(let c): $0.color = c
            }
        }
    }
    
    func remove(id: UUID) {
        items.removeAll { $0.id == id }
        finishEditing()
    }
    
    func reset() {
        items.removeAll()
        activeID = nil
        isPlacing = false
        waitForKeyboard = false
    }
    
    func keyboardDidChange(_ h: CGFloat, canvas: CGSize, imageSize: CGSize?) {
        if waitForKeyboard, h > 0 {
            placeText(in: canvas, keyboardH: h, imageSize: imageSize)
            return
        }
        if h == 0 {
            for i in items.indices {
                if let saved = items[i].parkedPosition {
                    items[i].position        = saved
                    items[i].parkedPosition  = nil
                }
            }
        }
        adjustPosition(canvas: canvas, keyboardH: h, imageSize: imageSize)
    }
    
    private func adjustPosition(canvas: CGSize, keyboardH: CGFloat, imageSize: CGSize?) {
        guard keyboardH > 0 else { return }
        
        let frame = CanvasFrame(canvas: canvas, keyboard: keyboardH, imageSize: imageSize)
        
        mutateActive { item in
            guard item.isEditing else { return }
            if item.parkedPosition == nil {
                item.parkedPosition = item.position
            }
            
            let y = min(max(item.position.y, frame.minY), frame.maxY)
            item.position = CGPoint(x: frame.canvas.width / 2, y: y)
        }
    }
    
    private func mutateActive(_ block: (inout TextItem) -> Void) {
        guard let id = activeID, let idx = items.firstIndex(where: {$0.id == id}) else { return }
        block(&items[idx])
    }
}

extension TextOverlayViewModel {
    enum Edit {
        case size(CGFloat)
        case color(Color)
    }
}
