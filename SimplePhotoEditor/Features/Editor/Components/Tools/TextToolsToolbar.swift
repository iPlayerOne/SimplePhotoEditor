import SwiftUI

struct TextToolsToolbar: ToolbarContent {
    @ObservedObject var vm: TextOverlayViewModel
    let onDone: () -> Void

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
            ColorPicker("", selection: $vm.currentColor)
                .labelsHidden()
                .controlSize(.small)

            Stepper("\(Int(vm.currentSize)) pt",
                    value: $vm.currentSize,
                    in: 10...72)
                .controlSize(.small)

            Spacer()

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
