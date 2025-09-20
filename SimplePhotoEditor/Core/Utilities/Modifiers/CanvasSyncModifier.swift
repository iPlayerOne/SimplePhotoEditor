import SwiftUI

struct CanvasSync: ViewModifier {
    let geo: GeometryProxy
    let metrics: CanvasMetrics
    let bottomChromeHeight: CGFloat

    @ObservedObject var vm: EditorViewModel
    @ObservedObject var textVM: TextOverlayViewModel
    let baseImage: UIImage?

    func body(content: Content) -> some View {
        content
            .onAppear { applyLayout() }
            .onChange(of: vm.previewImage) { applyLayout() }
            .onChange(of: vm.originalImage) {
                vm.canvasSize = metrics.canvasSize
                textVM.reset()
                applyLayout()
            }
            .onChange(of: geo.size) { applyLayout() }
            .onChange(of: vm.keyboardHeight) {
                let overlap = keyboardOverlap(in: geo,
                                              keyboardH: vm.keyboardHeight,
                                              bottomChrome: bottomChromeHeight,
                                              canvasH: metrics.h)
                textVM.keyboardDidChange(overlap, canvas: metrics.canvasSize, imageSize: baseImage?.size)
            }
    }

    private func applyLayout() {
        vm.canvasSize = metrics.canvasSize
        let overlap = keyboardOverlap(in: geo,
                                      keyboardH: vm.keyboardHeight,
                                      bottomChrome: bottomChromeHeight,
                                      canvasH: metrics.h)
        textVM.keyboardDidChange(overlap, canvas: metrics.canvasSize, imageSize: baseImage?.size)
    }

    private func keyboardOverlap(in geo: GeometryProxy,
                                 keyboardH: CGFloat,
                                 bottomChrome: CGFloat,
                                 canvasH: CGFloat) -> CGFloat {
        let safeBottom  = geo.safeAreaInsets.bottom
        let effectiveKB = max(0, keyboardH - safeBottom)
        let containerH  = max(0, geo.size.height - (bottomChrome + safeBottom))
        let localBottom = max(0, (containerH - canvasH) / 2)
        return max(0, effectiveKB - localBottom)
    }
}
