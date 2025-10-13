import SwiftUI
import Observation

struct TextToolsToolbar: View {
    @Namespace private var glassNamespace
    
    @Bindable var vm: TextOverlayViewModel
    let onDone: () -> Void
    
    private let swatches: [Color] = [.white, .black, .red, .orange, .yellow, .green, .blue, .purple]
    // Регулирует визуальный зазор между иконками слева (сохраняя единый стеклянный блок)
    private let leftItemPadding: CGFloat = 8
    private let leftItemSize: CGSize = .init(width: 44, height: 44)
    
    var body: some View {
        GlassEffectContainer(spacing: 0) {
            HStack(spacing: 0) {
                colorMenu
                    .frame(width: leftItemSize.width, height: leftItemSize.height)
                    .padding(.horizontal, leftItemPadding)
                    .glassEffect()
                    .glassEffectUnion(id: "textLeft", namespace: glassNamespace)
                
                sizeMenu
                    .frame(height: leftItemSize.height)
                    .padding(.horizontal, leftItemPadding)
                    .glassEffect()
                    .glassEffectUnion(id: "textLeft", namespace: glassNamespace)
                
                fontMenu
                    .frame(height: leftItemSize.height)
                    .padding(.horizontal, leftItemPadding)
                    .glassEffect()
                    .glassEffectUnion(id: "textLeft", namespace: glassNamespace)
                
                Spacer(minLength: 0)
                
                if let id = vm.activeID {
                    Button(role: .destructive) { vm.remove(id: id) } label: {
                        Image(systemName: "trash")
                            .frame(width: 44, height: 44)
                            .font(.title3)
                    }
                    .glassEffect()
                    .glassEffectUnion(id: "textRight", namespace: glassNamespace)
                }
                
                Button("Готово", action: onDone)
                    .frame(height: 44)
                    .padding(.horizontal, 14)
                    .font(.callout)
                    .glassEffect()
                    .glassEffectUnion(id: "textRight", namespace: glassNamespace)
            }
            .padding(.vertical, 8)
        }
        .padding(.horizontal)
    }
    
    
    private var colorMenu: some View {
        ColorPicker("", selection: $vm.currentColor, supportsOpacity: true)
            .labelsHidden()
            .contentShape(Rectangle()) // чтобы паддинг тоже был кликабельным
    }
    
    private var sizeMenu: some View {
        Menu {
            Picker("Size", selection: $vm.currentSize) {
                ForEach([12,14,16,18,24,32,48,72], id: \.self) { s in
                    Text("\(s) pt").tag(Double(s))
                }
            }
        } label: {
            Image(systemName: "textformat.size")
                .frame(width: leftItemSize.width, height: leftItemSize.height)
                .contentShape(Rectangle())
        }
    }
    
    private var fontMenu: some View {
        Menu(
            content: {
                Picker("Font", selection: $vm.currentFont) {
                    ForEach(vm.curatedFonts) { opt in
                        Text(opt.displayName).tag(opt)
                    }
                }
            },
            label: {
                Text("Aa")
                    .font(vm.currentFont.font(size: 16))
                    .frame(width: leftItemSize.width, height: leftItemSize.height)
                    .accessibilityLabel("Font")
                    .contentShape(Rectangle())
            }
        )
    }
}


#Preview("TextToolsToolbar") {
    var vm = TextOverlayViewModel()
    vm.currentSize = 24
    vm.currentColor = .white

    // показать кнопку «Удалить» и активное редактирование:
    let item = TextItem(
        text: "Текст",
        font: .system,
        fontSize: 24,
        color: .white,
        position: .zero,
        isEditing: true
    )
    vm.items = [item]
    vm.activeID = item.id

    return VStack {
        Spacer()
        TextToolsToolbar(vm: vm, onDone: {})
            .padding()
            .background(Color(.systemGroupedBackground))
    }
    .frame(height: 240) // чтобы было видно тень и стекло
}
