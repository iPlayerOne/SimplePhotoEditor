import SwiftUI

struct TextItemView: View {
    @Binding var item: TextItem
    let vm: TextOverlayViewModel
    
    @FocusState private var focusedID: UUID?
    @GestureState private var dragOffset: CGSize = .zero
    
    var body: some View {
        TextField("", text: $item.text)
            .id(item.id)
            .focused($focusedID, equals: item.id)
            .padding(6)
            .background(item.isEditing ? Color.black.opacity(0.3) : Color.clear)
            .font(.system(size: item.fontSize))
            .foregroundColor(item.color)
            .multilineTextAlignment(.center)
            .fixedSize()
            .position(x: item.position.x + dragOffset.width,
                      y: item.position.y + dragOffset.height)
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        if !item.isEditing {
                            state = value.translation
                        }
                    }
                    .onEnded { value in
                        if !item.isEditing {
                            item.position.x += value.translation.width
                            item.position.y += value.translation.height
                        }
                    }
            )
            .onAppear {
                print("📝 TextItemView: appeared for item \(item.id.uuidString) at position \(item.position)")
                print("📝 TextItemView: canvas size: \(UIScreen.main.bounds.size)")
                if item.isEditing {
                    print("📝 TextItemView: onAppear — устанавливаю фокус для item \(item.id.uuidString)")
                    DispatchQueue.main.async {
                        focusedID = item.id
                    }
                }
            }
            .onChange(of: item.isEditing) { old, editing in
                print("📝 TextItemView: isEditing changed to \(editing) for item \(item.id.uuidString)")
                if editing {
                    DispatchQueue.main.async {
                        focusedID = item.id
                    }
                } else {
                    focusedID = nil
                }
            }
            .onChange(of: focusedID) { old, new in
                print("📝 TextItemView: focusedID changed to \(new?.uuidString ?? "nil") for item \(item.id.uuidString)")
            }
    }
}
