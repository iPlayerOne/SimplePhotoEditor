import SwiftUI

struct EditorTopBar: View {
    @Binding var rotationCount: Int
    @Binding var isFlipped: Bool
    
    let onDrawTap: () -> Void
    let onTextTap: () -> Void
    let isDrawActive: Bool
    let isTextActive: Bool

    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 12) {
                Button {
                    rotationCount += 1
                } label: {
                    Image(systemName: "rotate.right")
                }
                Button {
                    isFlipped.toggle()
                } label: {
                    Image(systemName: "arrow.left.and.right")
                }
            }

            Spacer(minLength: 0)

            HStack(spacing: 16) {
                Button(action: onDrawTap) {
                    Image(systemName: "scribble")
                }
                .tint(isDrawActive ? .accentColor : .secondary)
                
                Button(action: onTextTap) {
                    Image(systemName: "textformat")
                }
                .tint(isTextActive ? .accentColor : .secondary)
            }
        }
        .modifier(PanelSurface())
    }
}
