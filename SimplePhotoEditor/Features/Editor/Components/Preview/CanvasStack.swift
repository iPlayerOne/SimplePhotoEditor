import SwiftUI
import PencilKit
import Observation

struct CanvasStack: View {
    let metrics: CanvasMetrics
    @ObservedObject var vm: EditorViewModel
    @Bindable var textVM: TextOverlayViewModel

    @Binding var drawing: PKDrawing
    @Binding var tool: PKInkingTool
    @Binding var isErasing: Bool
    @Binding var showSourceDialog: Bool

    let focus: FocusState<UUID?>.Binding
    let baseImage: UIImage?

    @State private var baseScale: CGFloat = 1
    @State private var currentScale: CGFloat = 1

    var body: some View {
        let maxSize       = metrics.canvasSize
        let containerSize = metrics.containerSize

        let turns = vm.rotationCount % 4
        let isRotated90 = (turns == 1 || turns == 3)

        let extraScale: CGFloat = {
            guard isRotated90, maxSize.height > 0 else { return 1 }
            return containerSize.height / maxSize.height
        }()

        let pinchGesture = MagnifyGesture()
            .onChanged { value in
                currentScale = baseScale * value.magnification
            }
            .onEnded { value in
                let minScale: CGFloat = 1.0

                var newScale = baseScale * value.magnification
                if newScale < minScale {
                    newScale = minScale
                }

                baseScale = newScale

                withAnimation(.spring(response: 0.35,
                                      dampingFraction: 0.9,
                                      blendDuration: 0.15)) {
                    currentScale = newScale
                }
            }

        let zoom = extraScale * currentScale

        ZStack {
            ZStack {
                PhotoLayer(
                    image: baseImage,
                    maxSize: maxSize,
                    onAddImage: { vm.originalImage == nil ? (showSourceDialog = true) : () },
                    contentMode: .fit
                )

                if baseImage != nil {
                    PencilCanvasView(drawing: $drawing, tool: tool, isErasing: isErasing)
                        .frame(width: maxSize.width, height: maxSize.height)
                        .allowsHitTesting(vm.mode == .draw)

                    TextOverlayLayer(
                        textVM: textVM,
                        focus: focus,
                        rotationQuarterTurns: vm.rotationCount
                    )
                    .frame(width: maxSize.width, height: maxSize.height)
                }
            }
            .frame(width: maxSize.width, height: maxSize.height)
            .contentShape(Rectangle())
            .canvasTransform(
                quarterTurns: vm.rotationCount,
                flippedHorizontally: vm.isFlippedHorizontally,
                frameSize: metrics.canvasSize
            )
            .scaleEffect(zoom)
            .simultaneousGesture(pinchGesture)

            if vm.mode == .text
                && textVM.items.isEmpty
                && textVM.activeID == nil
                && focus.wrappedValue == nil {
                Color.black.opacity(0.4)
                    .frame(width: maxSize.width, height: maxSize.height)
                    .allowsHitTesting(false)

                Text(String(localized: "editor.text.tap_to_add"))
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .frame(width: maxSize.width, height: maxSize.height, alignment: .center)
                    .allowsHitTesting(false)
            }
        }
    }
}
