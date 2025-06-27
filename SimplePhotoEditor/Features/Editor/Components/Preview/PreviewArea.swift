import SwiftUI
import PencilKit

struct PreviewArea: View {
    @ObservedObject var vm: EditorViewModel
    @ObservedObject var textVM: TextOverlayViewModel

    @Binding var drawing:   PKDrawing
    @Binding var tool:      PKInkingTool
    @Binding var isErasing: Bool

    @Binding var showSourceDialog: Bool

    @State private var scale: CGFloat = 1
    @GestureState private var pinch: CGFloat = 1

    private let heightRatio: CGFloat = 0.6

    private func localKeyboardHeight(_ hGlobal: CGFloat,
                                     geo: GeometryProxy) -> CGFloat {
        max(0, hGlobal - geo.safeAreaInsets.bottom)
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h: CGFloat = {
                if let ui = vm.previewImage {
                    let aspect = ui.size.width / ui.size.height
                    return w / aspect
                } else {
                    return w * heightRatio
                }
            }()

            let base = ZStack {
                PhotoLayer(image: vm.previewImage,
                           maxSize: CGSize(width: w, height: h),
                           onAddImage: { vm.originalImage == nil ? (showSourceDialog = true) : () })
                    .rotationEffect(.degrees(Double(vm.rotationCount) * 90))
                    .scaleEffect(x: vm.isFlippedHorizontally ? -1 : 1, y: 1)
                    .animation(.easeInOut(duration: 0.3), value: vm.rotationCount)
                    .animation(.easeInOut(duration: 0.3), value: vm.isFlippedHorizontally)

                if vm.previewImage != nil {
                    PencilCanvasView(drawing:   $drawing,
                                     tool:      tool,
                                     isErasing: isErasing)
                        .frame(width: w, height: h)
                        .allowsHitTesting(vm.markup == .draw)

                    TextOverlayLayer(textVM: textVM,
                                     enabled: vm.markup == .text)
                        .frame(width: w, height: h)
                }

                if vm.markup == .text && textVM.isPlacing && textVM.items.isEmpty {
                    Color.black.opacity(0.4).frame(width: w, height: h)
                    Text("Нажмите, чтобы добавить текст")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(.ultraThinMaterial,
                                    in: RoundedRectangle(cornerRadius: 8))
                        .frame(width: w, height: h, alignment: .center)
                }
            }
            .frame(width: w, height: h)
            .contentShape(Rectangle())
            .scaleEffect(scale * pinch)
            .clipped()
            .frame(maxHeight: .infinity, alignment: .center)
            .onAppear { 
                print("🎯 PreviewArea: onAppear - setting canvas size: \(CGSize(width: w, height: h))")
                vm.canvasSize = CGSize(width: w, height: h) 
            }
            .onChange(of: vm.keyboardHeight) { old, new in
                print("🎯 PreviewArea: keyboardHeight changed to: \(new)")
                let overlap = localKeyboardHeight(new, geo: geo)
                print("🎯 PreviewArea: calling keyboardDidChange with overlap: \(overlap)")
                textVM.keyboardDidChange(overlap, canvas: CGSize(width: w, height: h), imageSize: vm.previewImage.map { $0.size })
            }

            if vm.markup == .text && textVM.isPlacing {
                base
                    .gesture(
                        TapGesture()
                            .onEnded {
                                print("🎯 PreviewArea: Tap gesture detected (refactored)")
                                let overlap = localKeyboardHeight(vm.keyboardHeight, geo: geo)
                                print("🎯 PreviewArea: Calling placeCentered with canvas: \(CGSize(width: w, height: h)), keyboardH: \(overlap)")
                                textVM.placeCentered(
                                    in: CGSize(width: w, height: h),
                                    keyboardH: overlap,
                                    imageSize: vm.previewImage.map { $0.size }
                                )
                            }
                    )
                    .simultaneousGesture(
                        MagnificationGesture()
                            .updating($pinch) { v, s, _ in s = v }
                            .onEnded { v in scale *= v }
                    )
            } else {
                base
                    .simultaneousGesture(
                        MagnificationGesture()
                            .updating($pinch) { v, s, _ in s = v }
                            .onEnded { v in scale *= v }
                    )
            }
        }
    }
}
