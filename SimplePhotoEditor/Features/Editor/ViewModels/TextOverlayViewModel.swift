import SwiftUI
import Observation

@Observable
final class TextOverlayViewModel {
    var items: [TextItem] = []
    var activeID: UUID?
    var isPlacing: Bool = false

    var currentColor: Color = .white {
        didSet { apply(.color(currentColor)) }
    }

    var currentSize: Double = 24 {
        didSet { apply(.size(currentSize)) }
    }

    var currentFont: FontOption = .system {
        didSet { apply(.font(currentFont)) }
    }

    var curatedFonts: [FontOption] = [
        .system, .rounded, .serif, .monospaced,
        .named("Georgia"), .named("AvenirNext-Regular"), .named("Menlo")
    ]

    private var waitForKeyboard: Bool = false

    func enterPlacement() {
        isPlacing = true
        activeID  = nil
        waitForKeyboard = true
    }

    func placeText(in canvas: CGSize, keyboardH: CGFloat, imageSize: CGSize?) {
        let frame = CanvasFrame(canvas: canvas, keyboard: keyboardH, imageSize: imageSize)
        let gapAboveKeyboard: CGFloat = 12

        let y: CGFloat
        if keyboardH > 0 {
            y = max(frame.minY, frame.maxY - gapAboveKeyboard)
        } else {
            y = frame.canvas.height / 2
        }

        let p = CGPoint(x: canvas.width / 2, y: y)

        let item = TextItem(
            text: "Текст",
            font: currentFont,
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
        activeID = id
        isPlacing = false
        if editing { mutateActive { $0.isEditing = true } }
    }

    func finishEditing() {
        mutateActive { $0.isEditing = false }
        activeID = nil
        isPlacing = true
    }

    func apply(_ edit: Edit) {
        mutateActive {
            switch edit {
            case .size(let s):  $0.fontSize = s
            case .color(let c): $0.color = c
            case .font(let f):  $0.font = f
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
        adjustPosition(canvas: canvas, keyboardH: h, imageSize: imageSize)
    }

    private func adjustPosition(canvas: CGSize, keyboardH: CGFloat, imageSize: CGSize?) {
        guard keyboardH > 0 else { return }

        let frame = CanvasFrame(canvas: canvas, keyboard: keyboardH, imageSize: imageSize)

        mutateActive { item in
            guard item.isEditing else { return }
            let y = min(max(item.position.y, frame.minY), frame.maxY)
            item.position = CGPoint(x: frame.canvas.width / 2, y: y)
        }
    }

    private func mutateActive(_ block: (inout TextItem) -> Void) {
        guard let id = activeID,
              let idx = items.firstIndex(where: { $0.id == id })
        else { return }
        block(&items[idx])
    }
}

extension TextOverlayViewModel {
    enum Edit {
        case size(Double)
        case color(Color)
        case font(FontOption)
    }
}

fileprivate struct CanvasFrame {
    let canvas: CGSize
    let minY: CGFloat
    let maxY: CGFloat

    init(canvas: CGSize, keyboard: CGFloat, imageSize: CGSize?, textH: CGFloat = 44, margin: CGFloat = 8) {
        let canvasRect = CGRect(origin: .zero, size: canvas)
        let fit = aspectFitRect(aspect: imageSize ?? canvas, in: canvasRect)

        let vInset = fit.minY

        minY = vInset + textH/2 + margin
        maxY = canvas.height - vInset - textH/2 - margin - keyboard
        self.canvas = canvas
    }
}
