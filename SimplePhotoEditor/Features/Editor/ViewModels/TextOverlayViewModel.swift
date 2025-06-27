import SwiftUI
import Combine

@MainActor
final class TextOverlayViewModel: ObservableObject {

    @Published var items: [TextItem] = []
    @Published var activeID: UUID?
    @Published var isPlacing  = false

    @Published var currentColor: Color   = .white
    @Published var currentSize:  CGFloat = 24
    
    private var waitForKeyboard: Bool = false
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        print("""
    🔤 TextOverlayViewModel init
    Call stack:
    \(Thread.callStackSymbols.joined(separator: "\n"))
    """)
        $currentColor
            .sink { [weak self] in self?.apply(color: $0) }
            .store(in: &cancellables)
        $currentSize
            .sink { [weak self] in self?.apply(size: $0) }
            .store(in: &cancellables)
    }

    func enterPlacement() {
        print("🔤 TextOverlayViewModel: enterPlacement() - isPlacing = true")
        isPlacing = true
        activeID  = nil
    }

    func placeCentered(in canvas: CGSize, keyboardH: CGFloat, imageSize: CGSize?) {
        print("🔤 TextOverlayViewModel: placeCentered() - canvas: \(canvas), keyboardH: \(keyboardH), imageSize: \(String(describing: imageSize))")
        let textH: CGFloat = 44
        let safeMargin: CGFloat = 8

        // Размер изображения внутри canvas
        let imageHeight = imageSize?.height ?? canvas.height
        let imageWidth  = imageSize?.width  ?? canvas.width
        let aspectCanvas = canvas.width / canvas.height
        let aspectImage  = imageWidth / imageHeight

        // Вычисляем реальный frame изображения внутри canvas
        let displayedImageHeight: CGFloat
        if aspectImage > aspectCanvas {
            // Фото шире canvas — подгоняем по ширине
            displayedImageHeight = canvas.width / aspectImage
        } else {
            // Фото выше или равно canvas — подгоняем по высоте
            displayedImageHeight = canvas.height
        }
        let verticalInset = (canvas.height - displayedImageHeight) / 2

        let minY = verticalInset + textH/2 + safeMargin
        let maxY = canvas.height - verticalInset - textH/2 - safeMargin - keyboardH
        let visibleHeight = maxY - minY

        let y: CGFloat
        if visibleHeight < textH {
            y = canvas.height / 2
            print("⚠️ Недостаточно места для текста — размещаю по центру canvas")
        } else {
            y = minY + visibleHeight / 2
        }

        let x = canvas.width / 2
        let p = CGPoint(x: x, y: y)
        let item = TextItem(text: "Текст",
                            fontName: "System",
                            fontSize: currentSize,
                            color:    currentColor,
                            position: p,
                            isEditing: true)
        print("🔤 TextOverlayViewModel: creating new TextItem at position \(p)")
        items.append(item)
        activeID   = item.id
        isPlacing  = false
        print("🔤 TextOverlayViewModel: items count: \(items.count), activeID: \(activeID?.uuidString ?? "nil")")
    }
    
    func keyboardDidChange(_ h: CGFloat, canvas: CGSize, imageSize: CGSize?) {
        print("🔤 TextOverlayViewModel: keyboardDidChange() - h: \(h), canvas: \(canvas), waitForKeyboard: \(waitForKeyboard)")
        
        if waitForKeyboard, h > 0 {
            print("🔤 TextOverlayViewModel: keyboard appeared, placing text")
            waitForKeyboard = false
            placeCentered(in: canvas, keyboardH: h, imageSize: imageSize)
            return
        }
        adjustActivePosition(canvas: canvas, keyboardH: h, imageSize: imageSize)
    }

    func finishEditing() {
        print("🔤 TextOverlayViewModel: finishEditing() - activeID: \(activeID?.uuidString ?? "nil")")
        if let id = activeID,
           let i  = items.firstIndex(where: { $0.id == id }) {
            items[i].isEditing = false
            print("🔤 TextOverlayViewModel: finished editing item at index \(i)")
        }
        isPlacing = true
    }

    func apply(size: CGFloat) {
        print("🔤 TextOverlayViewModel: apply(size: \(size)) - activeID: \(activeID?.uuidString ?? "nil")")
        guard let id = activeID,
              let i  = items.firstIndex(where: { $0.id == id })
        else { 
            print("🔤 TextOverlayViewModel: no active item to apply size")
            return 
        }
        items[i].fontSize = size
        print("🔤 TextOverlayViewModel: applied size to item at index \(i)")
    }

    func apply(color: Color) {
        print("🔤 TextOverlayViewModel: apply(color: \(color)) - activeID: \(activeID?.uuidString ?? "nil")")
        guard let id = activeID,
              let i  = items.firstIndex(where: { $0.id == id })
        else { 
            print("🔤 TextOverlayViewModel: no active item to apply color")
            return 
        }
        items[i].color = color
        print("🔤 TextOverlayViewModel: applied color to item at index \(i)")
    }

    func adjustActivePosition(canvas: CGSize, keyboardH: CGFloat, imageSize: CGSize? = nil) {
        print("🔤 TextOverlayViewModel: adjustActivePosition() - canvas: \(canvas), keyboardH: \(keyboardH)")
        guard keyboardH > 0,
              let id = activeID,
              let i  = items.firstIndex(where: { $0.id == id }),
              items[i].isEditing
        else {
            print("🔤 TextOverlayViewModel: cannot adjust position - keyboardH: \(keyboardH), activeID: \(activeID?.uuidString ?? "nil"), isEditing: \(items.firstIndex(where: { $0.id == activeID }).map { items[$0].isEditing } ?? false)")
            return
        }
        let textH: CGFloat = 44
        let safeMargin: CGFloat = 8

        let imageHeight = imageSize?.height ?? canvas.height
        let imageWidth  = imageSize?.width  ?? canvas.width
        let aspectCanvas = canvas.width / canvas.height
        let aspectImage  = imageWidth / imageHeight

        let displayedImageHeight: CGFloat
        if aspectImage > aspectCanvas {
            displayedImageHeight = canvas.width / aspectImage
        } else {
            displayedImageHeight = canvas.height
        }
        let verticalInset = (canvas.height - displayedImageHeight) / 2

        let minY = verticalInset + textH/2 + safeMargin
        let maxY = canvas.height - verticalInset - textH/2 - safeMargin - keyboardH

        // Если текст уже в видимой части — не трогаем
        let currentY = items[i].position.y
        if currentY >= minY && currentY <= maxY {
            print("🔤 TextOverlayViewModel: текст уже в видимой части, не двигаю")
            return
        }

        // Если текст уходит под клавиатуру — сдвигаем вверх
        let y = min(max(currentY, minY), maxY)
        let newPosition = CGPoint(
            x: canvas.width / 2,
            y: y
        )
        items[i].position = newPosition
        print("🔤 TextOverlayViewModel: adjusted position to \(newPosition) for item at index \(i)")
    }
    
    func remove(id: UUID) {
        print("🔤 TextOverlayViewModel: remove(id: \(id.uuidString))")
        items.removeAll { $0.id == id }
        finishEditing()
        print("🔤 TextOverlayViewModel: items count after removal: \(items.count)")
    }

    func reset() {
        print("🔤 TextOverlayViewModel: reset() - clearing all text items")
        items.removeAll()
        activeID = nil
        isPlacing = false
    }
}
