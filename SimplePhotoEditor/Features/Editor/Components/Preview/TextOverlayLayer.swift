import SwiftUI

struct TextOverlayLayer: View {
    @ObservedObject var textVM: TextOverlayViewModel
    let enabled: Bool

    var body: some View {
        ZStack {
            ForEach($textVM.items, id: \.id) { $item in
                TextItemView(
                    item:    $item,
                    vm:  textVM
                )
            }
        }
    }
}
