import SwiftUI

struct TopToolsPanel: View {
    @ObservedObject var vm: EditorViewModel

    private let padding: CGFloat = 8        

    var body: some View {
        HStack(spacing: 16) {
            LeadingControls(
                rotationCount:        $vm.rotationCount,
                isFlippedHorizontally: $vm.isFlippedHorizontally
            )

            Spacer(minLength: 0)

            TrailingControls(
                markup: $vm.markup,
                onDrawTap: vm.startDraw,
                onTextTap: vm.startText)
        }
        .padding(.horizontal, padding * 1.5)
        .padding(.vertical,   padding)
        .background(.ultraThinMaterial)
    }
}
