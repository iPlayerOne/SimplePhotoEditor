//import SwiftUI
//
//struct TextToolsPanel: ToolbarContent {
//    @ObservedObject var textVM: TextOverlayViewModel
//        @ToolbarContentBuilder
//        var body: some ToolbarContent {
//            ToolbarItemGroup(placement: .keyboard) {
//                ColorPicker("", selection: $textVM.currentColor)
//                    .labelsHidden()
//                    .controlSize(.small)
//
//                // Размер текста
//                Stepper("\(Int(textVM.currentSize)) pt",
//                        value: $textVM.currentSize,
//                        in: 10...72)
//                    .controlSize(.small)
//
//                Spacer()
//
//                if let id = textVM.activeID {
//                    Button(role: .destructive) {
//                        textVM.remove(id: id)
//                    } label: {
//                        Image(systemName: "trash")
//                    }
//                    .controlSize(.small)
//                }
//
//                Button("Готово") {
//                    textVM.finishEditing()
//                }
//                    .controlSize(.small)
//            }
//        }
//    }
//
