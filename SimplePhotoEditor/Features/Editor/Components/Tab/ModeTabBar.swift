import SwiftUI

struct ModeTabBar: View {
    @Binding var selected: EditorMode

    var body: some View {
            HStack(spacing: 0) {
                ForEach(EditorMode.allCases) { mode in
                    ModeButton(
                        current:      $selected,
                        target:       mode,
                        systemName:   mode.iconName,
                        title:        mode.title,
                        widthFraction: 0.6
                    )
                }
            }
            .frame(height: 50)
        }
    }


#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @State var selectedMode: EditorMode = .filter
    ModeTabBar(selected: $selectedMode)
        .padding()
}
