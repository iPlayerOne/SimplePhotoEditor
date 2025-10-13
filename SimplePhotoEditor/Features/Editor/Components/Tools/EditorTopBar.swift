import SwiftUI

//struct EditorTopBar: View {
//    @Namespace private var glassNamespace
//
//    @Binding var rotationCount: Int
//    @Binding var isFlipped: Bool
//
//    let onDrawTap: () -> Void
//    let onTextTap: () -> Void
//    let isDrawActive: Bool
//    let isTextActive: Bool
//    
//    let edgeIndet: CGFloat = 4
//
//    var body: some View {
//        GlassEffectContainer(spacing: 0) {
//            HStack(spacing: 0) {
//                Button {
//                    rotationCount += 1
//                } label: {
//                    Image(systemName: "rotate.right")
//                        .toolbarGlyph(active: false)
//                        .padding(.leading, edgeIndet)
//                }
//                .glassEffect()
//                .glassEffectUnion(id: "leftGroup", namespace: glassNamespace)
//                
//
//                Button {
//                    isFlipped.toggle()
//                } label: {
//                    Image(systemName: "arrow.left.and.right.righttriangle.left.righttriangle.right")
//                        .toolbarGlyph(active: false)
//                        .padding(.trailing, edgeIndet)
//                }
//                .glassEffect()
//                .glassEffectUnion(id: "leftGroup", namespace: glassNamespace)
//                
//
//                Spacer()
//
//                Button(action: onDrawTap) {
//                    Image(systemName: "scribble")
//                        .toolbarGlyph(active: isDrawActive)
//                        .padding(.leading, edgeIndet)
//                }
//                .glassEffect()
//                .glassEffectUnion(id: "rightGroup", namespace: glassNamespace)
//                
//
//                Button(action: onTextTap) {
//                    Image(systemName: "textformat")
//                        .toolbarGlyph(active: isTextActive)
//                        .padding(.trailing, edgeIndet)
//                }
//                .glassEffect()
//                .glassEffectUnion(id: "rightGroup", namespace: glassNamespace)
//                
//            }
//            .padding(.vertical, 8)
//        }
//        .padding(.top, 8)
//    }
//}

import SwiftUI

struct EditorTopBar: View {
    @Namespace private var glassNS

    @Binding var rotationCount: Int
    @Binding var isFlipped: Bool

    let onDrawTap: () -> Void
    let onTextTap: () -> Void
    let isDrawActive: Bool
    let isTextActive: Bool

    var body: some View {
        GlassEffectContainer(spacing: 0) {
            HStack(spacing: 0) {
                HStack(spacing: 0) {
                    Button { rotationCount += 1 } label: {
                        Image(systemName: "rotate.right")
                            .toolbarGlyph(active: false)
                    }
                    .glassEffect()
                    .glassEffectUnion(id: "left", namespace: glassNS)

                    Button { isFlipped.toggle() } label: {
                        Image(systemName: "arrow.left.and.right.righttriangle.left.righttriangle.right")
                            .toolbarGlyph(active: false)
                    }
                    .glassEffect()
                    .glassEffectUnion(id: "left", namespace: glassNS)
                }
                .tint(.primary.opacity(0.9))

                Spacer(minLength: 8)

                HStack(spacing: 0) {
                    Button(action: onDrawTap) {
                        Image(systemName: "scribble")
                            .toolbarGlyph(active: isDrawActive)
                    }
                    .glassEffect()
                    .glassEffectUnion(id: "right", namespace: glassNS)

                    Button(action: onTextTap) {
                        Image(systemName: "textformat")
                            .toolbarGlyph(active: isTextActive)
                    }
                    .glassEffect()
                    .glassEffectUnion(id: "right", namespace: glassNS)
                }
                .tint(.primary.opacity(0.9))
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12) 
        }
        .padding(.top, 8)
        .glassEffectID("topbar", in: glassNS)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State var rotationCount: Int = 0
        @State var isFlipped: Bool = false

        var body: some View {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                VStack {
                    EditorTopBar(
                        rotationCount: $rotationCount,
                        isFlipped: $isFlipped,
                        onDrawTap: { print("Draw tapped") },
                        onTextTap: { print("Text tapped") },
                        isDrawActive: true,
                        isTextActive: false
                    )
                    Spacer()
                }
            }
        }
    }
    return PreviewWrapper()
}
