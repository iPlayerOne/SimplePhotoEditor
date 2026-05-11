import SwiftUI
import Observation

@Observable
final class TextOverlayViewModel {
    var items: [TextItem] = []
    var activeID: UUID?
    var isPlacing: Bool = false

    var currentColor: Color = .blue
    var currentSize: Double = 24
    var currentFont: FontOption = .system

    var curatedFonts: [FontOption] = [
        .system, .rounded, .serif, .monospaced,
        .named("Georgia"), .named("AvenirNext-Regular"), .named("Menlo")
    ]

    private var waitForKeyboard: Bool = false
    private var pendingRotationQuarterTurns: Int = 0

    var activeItem: TextItem? {
        items.first { $0.id == activeID }
    }

    func enterPlacement(rotationQuarterTurns: Int? = nil) {
        activeID = nil
        isPlacing = true
        waitForKeyboard = true
        if let r = rotationQuarterTurns { pendingRotationQuarterTurns = r }
    }

    func beginPlacingNewText(rotationQuarterTurns: Int? = nil) {
        isPlacing = true
        activeID = nil
        waitForKeyboard = true
        if let r = rotationQuarterTurns { pendingRotationQuarterTurns = r }
    }

    func placeText(in canvas: CGSize, keyboardH: CGFloat, imageSize: CGSize?, rotationQuarterTurns: Int? = nil) {
        let frame = CanvasFrame(canvas: canvas, keyboard: keyboardH, imageSize: imageSize)
        let gapAboveKeyboard: CGFloat = 12

        let y: CGFloat
        if keyboardH > 0 {
            y = max(frame.minY, frame.maxY - gapAboveKeyboard)
        } else {
            y = frame.canvas.height / 2
        }

        let p = CGPoint(x: canvas.width / 2, y: y)
        let quarter = (rotationQuarterTurns ?? pendingRotationQuarterTurns) % 4
        let baseRotation = Double(-90 * quarter)

        let item = TextItem(
            text: "Текст",
            font: currentFont,
            fontSize: currentSize,
            color: currentColor,
            position: p,
            isEditing: true,
            rotation: baseRotation
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
    }

    func apply(_ edit: Edit) {
        mutateActive {
            switch edit {
            case .size(let s):
                $0.fontSize = s
            case .color(let c):
                $0.color = c
            case .font(let f):
                $0.font = f
            }
        }
    }

    func clearSelection() {
        if activeID != nil {
            mutateActive { $0.isEditing = false }
        }
        activeID = nil
        isPlacing = false
        waitForKeyboard = false
    }

    func remove(id: UUID) {
        let removedActive = (id == activeID)
        items.removeAll { $0.id == id }
        if removedActive {
            clearSelection()
        }
    }

    func reset() {
        items.removeAll()
        activeID = nil
        isPlacing = false
        waitForKeyboard = false
        pendingRotationQuarterTurns = 0
    }

    func keyboardDidChange(_ h: CGFloat, canvas: CGSize, imageSize: CGSize?) {
        if waitForKeyboard, h > 0 {
            placeText(in: canvas, keyboardH: h, imageSize: imageSize, rotationQuarterTurns: pendingRotationQuarterTurns)
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
        else {
            return
        }
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
