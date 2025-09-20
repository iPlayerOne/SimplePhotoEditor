//import SwiftUI
//import PencilKit
//
//struct PreviewArea: View {
//    @ObservedObject var vm: EditorViewModel
//    @ObservedObject var textVM: TextOverlayViewModel
//    
//    @Binding var drawing: PKDrawing
//    @Binding var tool: PKInkingTool
//    @Binding var isErasing: Bool
//    @Binding var showSourceDialog: Bool
//    
//    @State private var scale: CGFloat = 1
//    @GestureState private var pinch: CGFloat = 1
//    var bottomChromeHeight: CGFloat = 0
//    let focus: FocusState<UUID?>.Binding
//    private let heightRatio: CGFloat = 0.6
//    
//    
//    private func localKeyboardHeight(_ hGlobal: CGFloat, geo: GeometryProxy) -> CGFloat {
//        max(0, hGlobal - geo.safeAreaInsets.bottom)
//    }
//    
//    var body: some View {
//        GeometryReader { geo in
//            let w = geo.size.width
//            let baseImage = vm.previewImage ?? vm.originalImage
//            let h = computedHeight(for: baseImage, width: w)
//            let canvasSize = CGSize(width: w, height: h)
//            let bottomInset = bottomChromeHeight + geo.safeAreaInsets.bottom
//            let containerH = max(0, geo.size.height - bottomInset)
//            
//            let pinchGesture = MagnifyGesture()
//                .updating($pinch) { value, state, _ in
//                    state = value.magnification
//                }
//                .onEnded { value in
//                    scale *= value.magnification
//                }
//            
//            let base = ZStack {
//                PhotoLayer(
//                    image: baseImage,
//                    maxSize: canvasSize,
//                    onAddImage: { vm.originalImage == nil ? (showSourceDialog = true) : () }
//                )
//                .rotationEffect(.degrees(Double(vm.rotationCount) * 90))
//                .scaleEffect(x: vm.isFlippedHorizontally ? -1 : 1, y: 1)
//                .animation(.easeInOut(duration: 0.3), value: vm.rotationCount)
//                .animation(.easeInOut(duration: 0.3), value: vm.isFlippedHorizontally)
//                
//                if baseImage != nil {
//                    PencilCanvasView(
//                        drawing:   $drawing,
//                        tool:      tool,
//                        isErasing: isErasing
//                    )
//                    .frame(width: w, height: h)
//                    .allowsHitTesting(vm.mode == .draw)
//                    
//                    TextOverlayLayer(textVM: textVM, enabled: vm.mode == .text, focus: focus)
//                        .frame(width: w, height: h)
//                }
//                
//                if vm.mode == .text && textVM.isPlacing && textVM.items.isEmpty {
//                    Color.black.opacity(0.4).frame(width: w, height: h)
//                    Text("Нажмите, чтобы добавить текст")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .padding()
//                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
//                        .frame(width: w, height: h, alignment: .center)
//                }
//            }
//                .frame(width: w, height: h)
//                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
//                .contentShape(Rectangle())
//                .scaleEffect(scale * pinch)
//                .clipped()
//                .simultaneousGesture(pinchGesture)
//                .onTapGesture {
//                    guard vm.mode == .text, textVM.isPlacing else { return }
//                    let overlap = keyboardOverlap(in: geo, keyboardH: vm.keyboardHeight, bottomChrome: bottomChromeHeight, canvasH: h)
//                    print("🪄 place tap — overlap:", overlap, "canvas:", canvasSize, "img:", baseImage?.size ?? .zero)
//                    textVM.placeText(in: canvasSize, keyboardH: overlap, imageSize: baseImage?.size)
//                }
//                .onAppear {
//                    applyLayoutUpdates(geo: geo, baseImage: baseImage, canvas: canvasSize)
//                }
//                .onChange(of: vm.previewImage) {
//                    applyLayoutUpdates(geo: geo, baseImage: baseImage, canvas: canvasSize)
//                }
//                .onChange(of: vm.originalImage) {
//                    drawing = PKDrawing()
//                    textVM.reset()
//                    applyLayoutUpdates(geo: geo, baseImage: baseImage, canvas: canvasSize)
//                }
//                .onChange(of: geo.size) {
//                    applyLayoutUpdates(geo: geo, baseImage: baseImage, canvas: canvasSize)
//                }
//                .onChange(of: vm.keyboardHeight) {
//                    let overlap = keyboardOverlap(in: geo, keyboardH: vm.keyboardHeight, bottomChrome: bottomChromeHeight, canvasH: h)
//                    print("📏 overlap:", overlap, "kb:", vm.keyboardHeight, "safe:", geo.safeAreaInsets.bottom, "bottomChrome:", bottomChromeHeight)
//                    textVM.keyboardDidChange(overlap, canvas: canvasSize, imageSize: baseImage?.size)
//                }
//            
//            VStack(spacing: 0) {
//                Spacer(minLength: 0)
//                base
//                Spacer(minLength: 0)
//            }
//            .frame(width: w, height: containerH)
//            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
//            .overlay(alignment: .center) {
//                Color.red.opacity(0.4).frame(height: 10)
//            }
//        }
//    }
//}
//

import SwiftUI
import PencilKit

struct PreviewArea: View {
    @ObservedObject var vm: EditorViewModel
    @ObservedObject var textVM: TextOverlayViewModel

    @Binding var drawing: PKDrawing
    @Binding var tool: PKInkingTool
    @Binding var isErasing: Bool
    @Binding var showSourceDialog: Bool
    
    let focus: FocusState<UUID?>.Binding

    var bottomChromeHeight: CGFloat = 0
    private let heightRatio: CGFloat = 1.0

    var body: some View {
        GeometryReader { geo in
            let layoutImage = vm.previewImage ?? vm.originalImage
            let metrics   = CanvasMetrics(
                geo: geo,
                baseImage: layoutImage,
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
                     bottomChromeHeight: bottomChromeHeight
                   )
                   .id(vm.inputData)
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

//            VStack(spacing: 0) {
//                Spacer(minLength: 0)
//                CanvasStack(
//                    metrics: metrics,
//                    vm: vm,
//                    textVM: textVM,
//                    drawing: $drawing,
//                    tool: $tool,
//                    isErasing: $isErasing,
//                    showSourceDialog: $showSourceDialog,
//                    focus: focus,
//                    bottomChromeHeight: bottomChromeHeight
//                )
//                .onTapGesture {
//                    guard vm.mode == .text, textVM.isPlacing else { return }
//                    let overlap = keyboardOverlap(
//                        in: geo,
//                        keyboardH: vm.keyboardHeight,
//                        bottomChrome: bottomChromeHeight,
//                        canvasH: metrics.h
//                    )
//                    textVM.placeText(
//                        in: metrics.canvasSize,
//                        keyboardH: overlap,
//                        imageSize: (vm.previewImage ?? vm.originalImage)?.size
//                    )
//                    
//                }
//                Spacer(minLength: 0)
//            }
//            .frame(width: geo.size.width, height: metrics.containerH, alignment: .center)
//            .padding(.top, 8)
//            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .frame(width: geo.size.width, height: metrics.containerSize.height, alignment: .center)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .clipped()
            .modifier(CanvasSync(geo: geo,
                                 metrics: metrics,
                                 bottomChromeHeight: bottomChromeHeight,
                                 vm: vm,
                                 textVM: textVM,
                                 baseImage: layoutImage))
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
