import SwiftUI
import Observation

struct TextToolsToolbar: View {
    @Namespace private var glassNamespace
    
    @Bindable var vm: TextOverlayViewModel
    let onDone: () -> Void
    
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
                
                Button(String(localized: "common.done"), action: onDone)
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
        ColorPicker(
            "",
            selection: Binding(
                get: {
                    return vm.activeItem?.color ?? vm.currentColor
                },
                set: { newValue in
                    if vm.activeItem != nil {
                        vm.apply(.color(newValue))
                    } else {
                        vm.currentColor = newValue
                    }
                }
            ),
            supportsOpacity: true
        )
        .labelsHidden()
        .contentShape(Rectangle())
    }
    
    private var sizeMenu: some View {
        Menu {
            Picker(String(localized: "editor.size.label"),
                   selection: Binding(
                    get: {
                        vm.activeID != nil ? (vm.activeItem?.fontSize ?? vm.currentSize) : vm.currentSize
                    },
                    set: { newValue in
                        if vm.activeID != nil {
                            vm.apply(.size(newValue))
                        } else {
                            vm.currentSize = newValue
                        }
                    })
            ) {
                ForEach([12,14,16,18,24,32,48,72], id: \.self) { s in
                    let fmt = String(localized: "editor.size.value.fmt")
                    Text(String(format: fmt, locale: .current, Int64(s))).tag(Double(s))
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
                Picker(String(localized: "editor.font.label"),
                       selection: Binding(
                        get: {
                            vm.activeID != nil ? (vm.activeItem?.font ?? vm.currentFont) : vm.currentFont
                        },
                        set: { newValue in
                            if vm.activeID != nil {
                                vm.apply(.font(newValue))
                            } else {
                                vm.currentFont = newValue
                            }
                        })
                ) {
                    ForEach(vm.curatedFonts) { opt in
                        Text(opt.displayName).tag(opt)
                    }
                }
            },
            label: {
                Text(String(localized: "editor.font.sample"))
                    .font((vm.activeItem?.font ?? vm.currentFont).font(size: 16))
                    .frame(width: leftItemSize.width, height: leftItemSize.height)
                    .accessibilityLabel(String(localized: "editor.font.label"))
                    .contentShape(Rectangle())
            }
        )
    }
}

#Preview("TextToolsToolbar") {
    var vm = TextOverlayViewModel()
    vm.currentSize = 24
    vm.currentColor = .white

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
    .frame(height: 240)
}
