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
        .onAppear {
            print("📄 TextOverlayLayer: appeared with \(textVM.items.count) items, enabled: \(enabled)")
        }
        .onChange(of: textVM.items.count) { old, count in
            print("📄 TextOverlayLayer: items count changed to \(count)")
        }
        .onChange(of: enabled) { old, enabled in
            print("📄 TextOverlayLayer: enabled changed to \(enabled)")
        }
    }
}
