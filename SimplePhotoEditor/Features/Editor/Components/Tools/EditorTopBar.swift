import SwiftUI

struct EditorTopBar: View {
    @Namespace private var glassNS

    @Binding var rotationCount: Int
    @Binding var isFlipped: Bool

    let onDrawTap: () -> Void
    let onTextTap: () -> Void
    let isDrawActive: Bool
    let isTextActive: Bool

    let canTransformImage: Bool

    var body: some View {
        GlassEffectContainer(spacing: 0) {
            HStack(spacing: 0) {
                if canTransformImage {
                    HStack(spacing: 0) {
                        Button { rotationCount += 1 } label: {
                            Image(systemName: "rotate.right")
                                .toolbarGlyph(active: false)
                        }
                        .glassEffect(.clear)
                        .glassEffectUnion(id: "left", namespace: glassNS)

                        Button { isFlipped.toggle() } label: {
                            Image(systemName: "arrow.left.and.right.righttriangle.left.righttriangle.right")
                                .toolbarGlyph(active: false)
                        }
                        .glassEffect(.clear)
                        .glassEffectUnion(id: "left", namespace: glassNS)
                    }
                    .tint(.primary.opacity(0.9))
                }

                Spacer(minLength: 8)

                HStack(spacing: 0) {
                    Button(action: onDrawTap) {
                        Image(systemName: "scribble")
                            .toolbarGlyph(active: isDrawActive)
                    }
                    .glassEffect(.clear)
                    .glassEffectUnion(id: "right", namespace: glassNS)

                    Button(action: onTextTap) {
                        Image(systemName: "textformat")
                            .toolbarGlyph(active: isTextActive)
                    }
                    .glassEffect(.clear)
                    .glassEffectUnion(id: "right", namespace: glassNS)
                }
                .tint(.primary.opacity(0.9))
            }
            .padding(.horizontal, 12)
        }
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
                        onDrawTap: { },
                        onTextTap: { },
                        isDrawActive: false,
                        isTextActive: false,
                        canTransformImage: true
                    )
                    Spacer()
                }
            }
        }
    }
    return PreviewWrapper()
}
