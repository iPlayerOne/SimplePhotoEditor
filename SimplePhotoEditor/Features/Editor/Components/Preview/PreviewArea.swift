import SwiftUI
import PencilKit

struct PreviewArea: View {
    @ObservedObject var vm: EditorViewModel
    @Bindable var textVM: TextOverlayViewModel

    @Binding var drawing: PKDrawing
    @Binding var tool: PKInkingTool
    @Binding var isErasing: Bool
    @Binding var showSourceDialog: Bool

    let focus: FocusState<UUID?>.Binding

    var bottomChromeHeight: CGFloat = 0
    private let heightRatio: CGFloat = 0.8

    var body: some View {
        GeometryReader { geo in
            let metricsImage = vm.originalImage ?? vm.previewImage
            let displayImage = vm.previewImage ?? vm.originalImage

            let metrics = CanvasMetrics(
                geo: geo,
                baseImage: metricsImage,
                bottomChrome: bottomChromeHeight,
                heightRatio: heightRatio
            )

            ZStack {
                CanvasStack(
                    metrics: metrics,
                    vm: vm,
                    textVM: textVM,
                    drawing: $drawing,
                    tool: $tool,
                    isErasing: $isErasing,
                    showSourceDialog: $showSourceDialog,
                    focus: focus,
                    bottomChromeHeight: bottomChromeHeight,
                    baseImage: displayImage
                )
                .onTapGesture {
                    guard vm.mode == .text, textVM.isPlacing else { return }
                    let overlap = keyboardOverlap(
                        in: geo,
                        keyboardH: vm.keyboardHeight,
                        bottomChrome: bottomChromeHeight,
                        canvasH: metrics.h
                    )
                    textVM.placeText(
                        in: metrics.canvasSize,
                        keyboardH: overlap,
                        imageSize: (vm.previewImage ?? vm.originalImage)?.size
                    )
                }
            }
            .frame(width: geo.size.width, height: metrics.containerSize.height, alignment: .center)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .clipped()
            .modifier(CanvasSync(
                geo: geo,
                metrics: metrics,
                bottomChromeHeight: bottomChromeHeight,
                vm: vm,
                textVM: textVM,
                baseImage: metricsImage
            ))
        }
    }
}

extension PreviewArea {
    func keyboardOverlap(in geo: GeometryProxy, keyboardH: CGFloat, bottomChrome: CGFloat, canvasH: CGFloat) -> CGFloat {
        let safeBottom  = geo.safeAreaInsets.bottom
        let effectiveKB = max(0, keyboardH - safeBottom)
        let containerH  = max(0, geo.size.height - (bottomChrome + safeBottom))
        let localBottom = max(0, (containerH - canvasH) / 2)
        return max(0, effectiveKB - localBottom)
    }
}
