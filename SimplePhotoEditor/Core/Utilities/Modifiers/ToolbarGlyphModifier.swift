import SwiftUI

struct ToolbarGlyphModifier: ViewModifier {
    let active: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        let styled = content
            .symbolRenderingMode(.monochrome)
            .font(.system(size: 20, weight: .semibold))
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
            

        if active {
            styled.foregroundStyle(.tint)
        } else {
            styled.foregroundStyle(.secondary)
        }
    }
}

extension View {
    func toolbarGlyph(active: Bool = false) -> some View {
        modifier(ToolbarGlyphModifier(active: active))
    }
}
