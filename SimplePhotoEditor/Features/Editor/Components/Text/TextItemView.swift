import SwiftUI

struct TextItemView: View {
  @Binding var item: TextItem
  @ObservedObject var vm: TextOverlayViewModel
  @FocusState private var foc: UUID?
  @GestureState private var drag: CGSize = .zero

  var body: some View {
    ZStack {
      // просмотр
      Text(item.text.isEmpty ? " " : item.text)
        .foregroundColor(item.color)
        .opacity(item.isEditing ? 0 : 1)

      // ввод
      TextField("", text: $item.text)
        .font(.system(size: item.fontSize))
        .foregroundColor(item.color)
        .disabled(!item.isEditing)
        .opacity(item.isEditing ? 1 : 0)
        .focused($foc, equals: item.id)
        .onSubmit { vm.finishEditing() }
    }
    .position(x: item.position.x + drag.width,
              y: item.position.y + drag.height)
    // drag доступен, когда не редактируем
    .highPriorityGesture(
      DragGesture()
        .updating($drag) { v,s,_ in if !item.isEditing { s = v.translation } }
        .onEnded { v in
           guard !item.isEditing else { return }
           item.position.x += v.translation.width
           item.position.y += v.translation.height })
    .contentShape(Rectangle())
    .onTapGesture {                       // повторный тап → редактируем
        guard !item.isEditing else { return }
        item.isEditing = true
        vm.activeID   = item.id
    }
    // синхронизация фокуса и activeID
    .onAppear { if item.isEditing { foc = item.id; vm.activeID = item.id } }
    .onChange(of: foc) { _, new in
        if new == nil && item.isEditing   { vm.finishEditing() }
        if new == item.id                { vm.activeID = item.id }
    }
  }
}
