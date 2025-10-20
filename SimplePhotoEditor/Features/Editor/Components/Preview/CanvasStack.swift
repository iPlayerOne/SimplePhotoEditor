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
    let bottomChromeHeight: CGFloat

    // ВАЖНО: используем тот же baseImage, что и в CanvasMetrics
    let baseImage: UIImage?

    @State private var scale: CGFloat = 1
    @GestureState private var pinch: CGFloat = 1

    var body: some View {
        let maxSize = metrics.canvasSize

        let pinchGesture = MagnifyGesture()
            .updating($pinch) { value, state, _ in state = value.magnification }
            .onEnded { value in scale *= value.magnification }

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

                TextOverlayLayer(textVM: textVM, focus: focus)
                    .frame(width: maxSize.width, height: maxSize.height)
            }

            if vm.mode == .text && textVM.isPlacing && textVM.items.isEmpty {
                Color.black.opacity(0.4).frame(width: maxSize.width, height: maxSize.height)
                Text("Нажмите, чтобы добавить текст")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .frame(width: maxSize.width, height: maxSize.height, alignment: .center)
            }
        }
        .frame(width: maxSize.width, height: maxSize.height)
        .contentShape(Rectangle())
        .canvasTransform(
            quarterTurns: vm.rotationCount,
            flippedHorizontally: vm.isFlippedHorizontally,
            frameSize: metrics.canvasSize
        )
        .scaleEffect(scale * pinch)
        .simultaneousGesture(pinchGesture)
    }
}
