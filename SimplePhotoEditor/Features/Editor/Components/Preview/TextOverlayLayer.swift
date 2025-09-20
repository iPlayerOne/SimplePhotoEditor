import SwiftUI

struct TextOverlayLayer: View {
    @ObservedObject var textVM: TextOverlayViewModel
    let enabled: Bool
    let focus: FocusState<UUID?>.Binding
    

    var body: some View {
        ZStack {
            ForEach($textVM.items, id: \.id) { $item in
                TextItemView(
                    item:    $item,
                    vm:  textVM,
                    focus: focus
                )
            }
        }
    }
}
