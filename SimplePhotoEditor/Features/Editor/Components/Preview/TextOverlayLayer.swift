import SwiftUI
import Observation

struct TextOverlayLayer: View {
    @Bindable var textVM: TextOverlayViewModel
    let focus: FocusState<UUID?>.Binding
    let rotationQuarterTurns: Int

    var body: some View {
        ZStack {
            ForEach(textVM.items) { item in
                TextItemView(item: item, vm: textVM, focus: focus)
                    .rotationEffect(.degrees(item.rotation))
            }
        }
    }
}
