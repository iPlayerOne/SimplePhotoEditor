import SwiftUI
import Observation

struct TextOverlayLayer: View {
    @Bindable var textVM: TextOverlayViewModel
    let focus: FocusState<UUID?>.Binding

    var body: some View {
        ZStack {
            ForEach(textVM.items) { item in
                TextItemView(item: item, vm: textVM, focus: focus)
            }
        }
    }
}
