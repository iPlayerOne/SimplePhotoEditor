import SwiftUI
import Observation

struct TextItemView: View {
    @Bindable var item: TextItem
    let vm: TextOverlayViewModel
    var focus: FocusState<UUID?>.Binding

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
            .focused(focus, equals: item.id)
            .padding(6)
            .background(item.isEditing ? Color.black.opacity(0.3) : Color.clear)
            .font(item.font.font(size: CGFloat(item.fontSize)))
            .foregroundColor(item.color)
            .multilineTextAlignment(.center)
            .fixedSize()
            .submitLabel(.done)
            .position(x: item.position.x + dragOffset.width,
                      y: item.position.y + dragOffset.height)
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: item.position)
            .simultaneousGesture(drag)
            .onTapGesture {
                if vm.activeID == item.id {
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
            .onChange(of: focus.wrappedValue) { _, newFocus in
                if newFocus == item.id {
                    vm.setActive(id: item.id, editing: true)
                } else if item.isEditing {
                    vm.finishEditing()
                }
            }
    }
}
