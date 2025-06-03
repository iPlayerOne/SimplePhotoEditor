//
//  PreviewArea.swift
//  SimplePhotoEditor
//

import SwiftUI
import PencilKit

struct PreviewArea: View {
    @ObservedObject var vm: EditorViewModel
    @ObservedObject var textVM: TextOverlayViewModel

    @Binding var drawing:   PKDrawing
    @Binding var tool:      PKInkingTool
    @Binding var isErasing: Bool

    // масштаб / пинч-жест
    @State private var scale: CGFloat = 1
    @GestureState private var pinch: CGFloat = 1

    private let heightRatio: CGFloat = 0.6          // когда фото ещё нет

    // MARK: – helper
    /// Переводит глобальную высоту клавиатуры в координаты холста
    private func localKeyboardHeight(_ hGlobal: CGFloat,
                                     geo: GeometryProxy) -> CGFloat {
        max(0, hGlobal - geo.safeAreaInsets.bottom)
    }

    var body: some View {
        GeometryReader { geo in
            // ───── размеры холста ─────
            let w = geo.size.width
            let h: CGFloat = {
                if let ui = vm.previewImage {
                    let aspect = ui.size.width / ui.size.height
                    return w / aspect
                } else {
                    return w * heightRatio
                }
            }()

            // ───── канва ─────
            ZStack {
                PhotoLayer(image: vm.previewImage,
                           maxSize: CGSize(width: w, height: h))
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

                // затемнение + подсказка
                if vm.markup == .text && textVM.isPlacing {
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
            .coordinateSpace(name: "canvas")
            .contentShape(Rectangle())

            // ───── пинч-масштаб ─────
            .simultaneousGesture(
                MagnificationGesture()
                    .updating($pinch) { v, s, _ in s = v }
                    .onEnded { v in scale *= v }
            )

            // ───── тап → новый текст ─────
            .gesture(
                TapGesture()
                    .onEnded {
                        guard vm.markup == .text, textVM.isPlacing else { return }

                        let overlap = localKeyboardHeight(vm.keyboardHeight, geo: geo)

                        textVM.placeCentered(
                            in: CGSize(width: w, height: h),
                            keyboardH: overlap
                        )
                    }
            )

            .scaleEffect(scale * pinch)
            .clipped()
            .frame(maxHeight: .infinity, alignment: .center)

            // актуальный размер холста в VM
            .onAppear { vm.canvasSize = CGSize(width: w, height: h) }

            // клавиатура изменилась → двигаем активный слой
            .onChange(of: vm.keyboardHeight) { newH in
                let overlap = localKeyboardHeight(newH, geo: geo)

                textVM.adjustActivePosition(
                    canvas: CGSize(width: w, height: h),
                    keyboardH: overlap
                )
            }
        }
    }
}
