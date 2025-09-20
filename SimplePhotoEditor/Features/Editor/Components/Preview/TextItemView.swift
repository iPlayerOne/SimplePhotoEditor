import SwiftUI

//struct TextItemView: View {
//    @Binding var item: TextItem
//    let vm: TextOverlayViewModel
//    
//    @FocusState private var isFocused: Bool
//    @GestureState private var dragOffset: CGSize = .zero
//    
//    private var drag: some Gesture {
//        DragGesture()
//            .updating($dragOffset) { value, state, _ in
//                guard !item.isEditing else { return }
//                state = value.translation
//            }
//            .onEnded { value in
//                guard !item.isEditing else { return }
//                item.position.x += value.translation.width
//                item.position.y += value.translation.height
//            }
//    }
//    
//    private var tap: some Gesture {
//        TapGesture()
//            .onEnded {
//                if item.id == vm.activeID {
//                    vm.setActive(id: item.id, editing: true)
//                } else {
//                    vm.setActive(id: item.id)
//                }
//            }
//    }
//    
//    var body: some View {
//        TextField("", text: $item.text)
//            .id(item.id)
//            .focused($isFocused)
//        
//            .padding(6)
//            .background(item.isEditing ? Color.black.opacity(0.3) : Color.clear)
//            .font(.system(size: item.fontSize))
//            .foregroundColor(item.color)
//            .multilineTextAlignment(.center)
//            .fixedSize()
//            .submitLabel(.done)
//            .position(x: item.position.x + dragOffset.width,
//                      y: item.position.y + dragOffset.height)
//            .animation(.spring(response: 0.35,
//                                           dampingFraction: 0.85),
//                                   value: item.position)
//            .gesture(drag)
//            .gesture(tap)
//            .onAppear {
//                if item.isEditing {
//                    isFocused = true
//                }
//            }
//            .onSubmit { vm.finishEditing() }
//            .onChange(of: isFocused) { focused in
//                if focused {
//                    vm.setActive(id: item.id, editing: true)
//                } else if item.isEditing {
//                    vm.finishEditing()
//                }
//            }
//        
//        
//    }
//}

struct TextItemView: View {
    @Binding var item: TextItem
    let vm: TextOverlayViewModel

    let focus: FocusState<UUID?>.Binding
    @GestureState private var dragOffset: CGSize = .zero

    private var drag: some Gesture {
        DragGesture()
            .updating($dragOffset) { value, state, _ in
                guard !item.isEditing else { return }
                state = value.translation
            }
            .onEnded { value in
                guard !item.isEditing else { return }
                item.position.x += value.translation.width
                item.position.y += value.translation.height
            }
    }

    var body: some View {
        TextField("", text: $item.text)
            .id(item.id)
            .focused(focus, equals: item.id)
            .padding(6)
            .background(item.isEditing ? Color.black.opacity(0.3) : Color.clear)
            .font(.system(size: item.fontSize))
            .foregroundColor(item.color)
            .multilineTextAlignment(.center)
            .fixedSize()
            .submitLabel(.done)
            .position(x: item.position.x + dragOffset.width,
                      y: item.position.y + dragOffset.height)
            .animation(.spring(response: 0.35, dampingFraction: 0.85),
                       value: item.position)
            .simultaneousGesture(drag)
            .onTapGesture {
                if item.id == vm.activeID {
                    vm.setActive(id: item.id, editing: true)
                    focus.wrappedValue = item.id
                } else {
                    vm.setActive(id: item.id)
                }
            }
            .onAppear {
                if item.isEditing {
                    focus.wrappedValue = item.id
                }
            }
            .onSubmit {
                focus.wrappedValue = nil
                vm.finishEditing()
            }
            .onChange(of: focus.wrappedValue) {
                if focus.wrappedValue == item.id {
                    vm.setActive(id: item.id, editing: true)
                } else if item.isEditing {
                    // потеряли фокус (тап вне поля и т.п.) — завершаем
                    vm.finishEditing()
                }
            }
    }
}
