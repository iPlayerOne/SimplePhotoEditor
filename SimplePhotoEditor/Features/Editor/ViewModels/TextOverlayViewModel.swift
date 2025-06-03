import SwiftUI
import Combine

@MainActor
final class TextOverlayViewModel: ObservableObject {

    @Published var items: [TextItem] = []
    @Published var activeID: UUID?
    @Published var isPlacing  = false

    @Published var currentColor: Color   = .white
    @Published var currentSize:  CGFloat = 24

    func enterPlacement() {
        isPlacing = true
        activeID  = nil
    }

    func placeCentered(in canvas: CGSize, keyboardH: CGFloat) {
        let textH: CGFloat = 44
        let p = CGPoint(x: canvas.width/2,
                        y: canvas.height - keyboardH - textH/2 - 8)

        let item = TextItem(text: "",
                            fontName: "System",
                            fontSize: currentSize,
                            color:    currentColor,
                            position: p,
                            isEditing: true)

        items.append(item)
        activeID   = item.id
        isPlacing  = false
    }

    func finishEditing() {
        if let id = activeID,
           let i  = items.firstIndex(where: { $0.id == id }) {
            items[i].isEditing = false
        }
        activeID = nil
        isPlacing = false
    }

    func apply(size: CGFloat) {
        guard let id = activeID,
              let i  = items.firstIndex(where: { $0.id == id })
        else { return }
        items[i].fontSize = size
    }

    func apply(color: Color) {
        guard let id = activeID,
              let i  = items.firstIndex(where: { $0.id == id })
        else { return }
        items[i].color = color
    }

    func adjustActivePosition(canvas: CGSize, keyboardH: CGFloat) {
        guard keyboardH > 0,
              let id = activeID,
              let i  = items.firstIndex(where: { $0.id == id }),
              items[i].isEditing
        else { return }

        let textH: CGFloat = 44
        items[i].position = CGPoint(
            x: canvas.width / 2,
            y: canvas.height - keyboardH - textH/2 - 8
        )
    }
    
    func remove(id: UUID) {
            items.removeAll { $0.id == id }
            finishEditing()                 
        }
}
