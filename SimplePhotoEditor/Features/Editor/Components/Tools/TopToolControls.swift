import SwiftUI

struct LeadingControls: View {
    @Binding var rotationCount: Int
    @Binding var isFlippedHorizontally: Bool

    var body: some View {
        HStack(spacing: 12) {
            Button {
                rotationCount += 1
            } label: {
                Image(systemName: "rotate.right")
                    .font(.title2)
                    .frame(width: 32, height: 32)
            }

            Button {
                isFlippedHorizontally.toggle()
            } label: {
                Image(systemName: "arrow.left.and.right.righttriangle.left.righttriangle.right")
                    .font(.title2)
                    .frame(width: 32, height: 32)
            }
        }
    }
}

struct TrailingControls: View {
    @Binding var markup: MarkupTool
    let onDrawTap: () -> Void
    let onTextTap: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Кнопка Draw
            Button(action: onDrawTap) {
                Image(systemName: MarkupTool.draw.iconName)
                    .font(.title2)
                    .frame(width: 32, height: 32)
                    .foregroundColor(markup == .draw ? .accentColor : .secondary)
            }

            // Кнопка Text
            Button(action: onTextTap) {
                Image(systemName: MarkupTool.text.iconName)
                    .font(.title2)
                    .frame(width: 32, height: 32)
                    .foregroundColor(markup == .text ? .accentColor : .secondary)
            }
        }
        .controlSize(.large)
        .padding(.horizontal, 8)   
    }
}
