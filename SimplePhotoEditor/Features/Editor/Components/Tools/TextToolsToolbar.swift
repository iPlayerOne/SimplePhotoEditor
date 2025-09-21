import SwiftUI
import Observation

struct TextToolsToolbar: ToolbarContent {
    @Bindable var vm: TextOverlayViewModel
    let onDone: () -> Void

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .keyboard) {
                ColorPicker("", selection: $vm.currentColor, supportsOpacity: true).labelsHidden()
                .controlSize(.mini)
                Menu {
                    Picker("Size", selection: $vm.currentSize) {
                        ForEach([12,14,16,18,24,32,48,72], id: \.self) { s in
                            Text("\(s) pt").tag(Double(s))
                        }
                    }
                } label: { Image(systemName: "textformat.size") }
                .controlSize(.mini)

                Picker(selection: $vm.currentFont) {
                    ForEach(vm.curatedFonts) { opt in
                        Text(opt.displayName).tag(opt)
                    }
                } label: { Image(systemName: "textformat") }
                .pickerStyle(.menu)
                .controlSize(.mini)
            }

        ToolbarSpacer(.fixed)

        ToolbarItem(placement: .keyboard) {
            if let id = vm.activeID {
                Button(role: .destructive) { vm.remove(id: id) } label: {
                    Image(systemName: "trash")
                }
                .controlSize(.mini)
            }
        }
        
        ToolbarItem(placement: .keyboard) {
            Button("Готово", action: onDone)
                .controlSize(.mini)
        }
    }
}
