//import SwiftUI
//
//struct TextItemView: View {
//    @Binding var item: TextItem
//    @ObservedObject var vm: TextOverlayViewModel       // ← единый нейминг
//    @FocusState private var foc: UUID?
//
//    var body: some View {
//        Group {
//            if item.isEditing {
//                TextField("", text: $item.text)
//                    .font(.system(size: item.fontSize))
//                    .fixedSize()
//                    .focused($foc, equals: item.id)
//                    .onAppear { foc = item.id }
//                    .onSubmit { vm.finishEditing() }
//            } else {
//                Text(item.text.isEmpty ? " " : item.text)
//                    .foregroundColor(item.color)
//                    .font(.system(size: item.fontSize))
//                    .fixedSize()
//            }
//        }
//        .position(item.position)
//        .liftable(if: item.isEditing, centered: true)
//        // ───────── добавили: перетаскивание и hit-testing ─────────
//        .draggable(enabled: !item.isEditing, coordinateSpace: .named("canvas"))
//        .allowsHitTesting(!item.isEditing || vm.isPlacing)
//         ───────── единый жест тап ─────────
//        .onTapGesture {
//            vm.activeID = item.id
//            item.isEditing = true
//        }
//        // ───────── сброс фокуса при переключении слоя ─────────
//        .onChange(of: vm.activeID) { _, newID in
//            if newID != item.id {
//                foc = nil
//                item.isEditing = false
//            }
//        }
//    }
//}
