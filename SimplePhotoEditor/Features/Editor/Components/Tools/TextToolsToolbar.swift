import SwiftUI

struct TextToolsToolbar: ToolbarContent {
    @ObservedObject var vm: TextOverlayViewModel
    let onDone: () -> Void
    
    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            ColorPicker("", selection: $vm.currentColor)
                .labelsHidden()
                .controlSize(.small)
            
            HStack(spacing: 8) {
                Image(systemName: "textformat.size.smaller")
                Slider(value: $vm.currentSize, in: 10...72, step: 1)
                    .frame(width: 140) // фиксируем ширину
                Image(systemName: "textformat.size.larger")
            }
            
            Spacer(minLength: 8)
            
            if let id = vm.activeID {
                Button(role: .destructive) {
                    vm.remove(id: id)
                } label: { Image(systemName: "trash") }
                    .controlSize(.small)
            }
            
            Button("Готово", action: onDone)
                .controlSize(.small)
        }
    }
}
