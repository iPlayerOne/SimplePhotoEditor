//import SwiftUI
//
//struct TextItemView: View {
//    @Binding var item: TextItem
//    @ObservedObject var vm: TextOverlayViewModel
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
//            }
//        }
//        .position(item.position)
//        .liftable(if: item.isEditing, centered: true)
//        .onTapGesture {
//            vm.activeID = item.id
//            item.isEditing = true
//        }
//    }
//} 
