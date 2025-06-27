# TextEditingFlow - Флоу добавления и редактирования текста (актуальное состояние)

Полный код и архитектурные замечания по флоу добавления и редактирования текста в редакторе. Включены все актуальные принты для отладки и рекомендации по архитектуре.

## Содержание

- [Модель текстового элемента](#модель-текстового-элемента)
- [ViewModel для работы с текстом](#viewmodel-для-работы-с-текстом)
- [Представления](#представления)
- [Сервисы](#сервисы)
- [Интеграция с EditorViewModel](#интеграция-с-editorviewmodel)

---

## Архитектурные замечания

- ViewModel для редактора (`EditorViewModel`) создаётся через DI-контейнер в RootView, что не является best practice для SwiftUI. Рекомендуется создавать его как `@StateObject` внутри `EditorView`.
- `TextOverlayViewModel` создаётся внутри `EditorViewModel` и используется для управления текстовыми слоями.
- В коде добавлены подробные `print`-отладчики для отслеживания жизненного цикла и событий флоу текста.

---

## Модель текстового элемента

```swift
import SwiftUI

struct TextItem: Identifiable {
    let id = UUID()
    var text:      String
    var fontName:  String
    var fontSize:  CGFloat
    var color:     Color
    var position:  CGPoint
    var isEditing  = false
}
```

---

## ViewModel для работы с текстом (TextOverlayViewModel)

```swift
import SwiftUI
import Combine

@MainActor
final class TextOverlayViewModel: ObservableObject {
    @Published var items: [TextItem] = []
    @Published var activeID: UUID?
    @Published var isPlacing  = false
    @Published var currentColor: Color   = .white
    @Published var currentSize:  CGFloat = 24
    
    private var waitForKeyboard: Bool = false
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        print("🔤 TextOverlayViewModel: init")
        $currentColor
            .sink { [weak self] in self?.apply(color: $0) }
            .store(in: &cancellables)
        $currentSize
            .sink { [weak self] in self?.apply(size: $0) }
            .store(in: &cancellables)
    }

    func enterPlacement() {
        print("🔤 TextOverlayViewModel: enterPlacement() - isPlacing = true")
        isPlacing = true
        activeID  = nil
    }

    func placeCentered(in canvas: CGSize, keyboardH: CGFloat) {
        print("🔤 TextOverlayViewModel: placeCentered() - canvas: \(canvas), keyboardH: \(keyboardH)")
        guard keyboardH > 0 else {
            print("🔤 TextOverlayViewModel: keyboardH <= 0, waiting for keyboard")
            waitForKeyboard = true
            return
        }
        let textH: CGFloat = 44
        let p = CGPoint(x: canvas.width/2,
                        y: canvas.height - keyboardH - textH/2 - 8)
        let item = TextItem(text: "",
                            fontName: "System",
                            fontSize: currentSize,
                            color:    currentColor,
                            position: p,
                            isEditing: true)
        print("🔤 TextOverlayViewModel: creating new TextItem at position \(p)")
        items.append(item)
        activeID   = item.id
        isPlacing  = false
        print("🔤 TextOverlayViewModel: items count: \(items.count), activeID: \(activeID?.uuidString ?? "nil")")
    }
    
    func keyboardDidChange(_ h: CGFloat, canvas: CGSize) {
        print("🔤 TextOverlayViewModel: keyboardDidChange() - h: \(h), canvas: \(canvas), waitForKeyboard: \(waitForKeyboard)")
        if waitForKeyboard, h > 0 {
            print("🔤 TextOverlayViewModel: keyboard appeared, placing text")
            waitForKeyboard = false
            placeCentered(in: canvas, keyboardH: h)
            return
        }
        adjustActivePosition(canvas: canvas, keyboardH: h)
    }

    func finishEditing() {
        print("🔤 TextOverlayViewModel: finishEditing() - activeID: \(activeID?.uuidString ?? "nil")")
        if let id = activeID,
           let i  = items.firstIndex(where: { $0.id == id }) {
            items[i].isEditing = false
            print("🔤 TextOverlayViewModel: finished editing item at index \(i)")
        }
        activeID = nil
        isPlacing = true
    }

    func apply(size: CGFloat) {
        print("🔤 TextOverlayViewModel: apply(size: \(size)) - activeID: \(activeID?.uuidString ?? "nil")")
        guard let id = activeID,
              let i  = items.firstIndex(where: { $0.id == id })
        else { 
            print("🔤 TextOverlayViewModel: no active item to apply size")
            return 
        }
        items[i].fontSize = size
        print("🔤 TextOverlayViewModel: applied size to item at index \(i)")
    }

    func apply(color: Color) {
        print("🔤 TextOverlayViewModel: apply(color: \(color)) - activeID: \(activeID?.uuidString ?? "nil")")
        guard let id = activeID,
              let i  = items.firstIndex(where: { $0.id == id })
        else { 
            print("🔤 TextOverlayViewModel: no active item to apply color")
            return 
        }
        items[i].color = color
        print("🔤 TextOverlayViewModel: applied color to item at index \(i)")
    }

    func adjustActivePosition(canvas: CGSize, keyboardH: CGFloat) {
        print("🔤 TextOverlayViewModel: adjustActivePosition() - canvas: \(canvas), keyboardH: \(keyboardH)")
        guard keyboardH > 0,
              let id = activeID,
              let i  = items.firstIndex(where: { $0.id == id }),
              items[i].isEditing
        else { 
            print("🔤 TextOverlayViewModel: cannot adjust position - keyboardH: \(keyboardH), activeID: \(activeID?.uuidString ?? "nil"), isEditing: \(items.firstIndex(where: { $0.id == activeID }).map { items[$0].isEditing } ?? false)")
            return 
        }
        let textH: CGFloat = 44
        let newPosition = CGPoint(
            x: canvas.width / 2,
            y: canvas.height - keyboardH - textH/2 - 8
        )
        items[i].position = newPosition
        print("🔤 TextOverlayViewModel: adjusted position to \(newPosition) for item at index \(i)")
    }
    
    func remove(id: UUID) {
        print("🔤 TextOverlayViewModel: remove(id: \(id.uuidString))")
        items.removeAll { $0.id == id }
        finishEditing()
        print("🔤 TextOverlayViewModel: items count after removal: \(items.count)")
    }
}
```

---

## Представления

### TextItemView - Представление отдельного текстового элемента

```swift
import SwiftUI

struct TextItemView: View {
    @Binding var item: TextItem
    let vm: TextOverlayViewModel
    @FocusState private var focusedID: UUID?
    var body: some View {
        TextField("", text: $item.text)
            .focused($focusedID, equals: item.id)
            .onChange(of: item.isEditing) { editing in
                print("📝 TextItemView: isEditing changed to \(editing) for item \(item.id.uuidString)")
                focusedID = editing ? item.id : nil
            }
            .onChange(of: focusedID) { new in
                print("📝 TextItemView: focusedID changed to \(new?.uuidString ?? "nil") for item \(item.id.uuidString)")
                if new != item.id, item.isEditing {
                    print("📝 TextItemView: losing focus, calling finishEditing")
                    vm.finishEditing()
                }
            }
            .font(.system(size: item.fontSize))
            .foregroundColor(item.color)
            .multilineTextAlignment(.center)
            .position(item.position)
            .onAppear {
                print("📝 TextItemView: appeared for item \(item.id.uuidString) at position \(item.position)")
            }
    }
}
```

### TextOverlayLayer - Слой для отображения всех текстовых элементов

```swift
import SwiftUI

struct TextOverlayLayer: View {
    @ObservedObject var textVM: TextOverlayViewModel
    let enabled: Bool
    var body: some View {
        ZStack {
            ForEach($textVM.items, id: \.id) { $item in
                TextItemView(
                    item:    $item,
                    vm:  textVM
                )
            }
        }
        .onAppear {
            print("📄 TextOverlayLayer: appeared with \(textVM.items.count) items, enabled: \(enabled)")
        }
        .onChange(of: textVM.items.count) { count in
            print("📄 TextOverlayLayer: items count changed to \(count)")
        }
        .onChange(of: enabled) { enabled in
            print("📄 TextOverlayLayer: enabled changed to \(enabled)")
        }
    }
}
```

### TextToolsToolbar - Панель инструментов для работы с текстом

```swift
import SwiftUI

struct TextToolsToolbar: ToolbarContent {
    @ObservedObject var vm: TextOverlayViewModel
    let onDone: () -> Void          // позволяет кастомно закрывать

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
```

### TrailingControls - Кнопки управления текстом в верхней панели

```swift
import SwiftUI

struct TrailingControls: View {
    @Binding var markup: MarkupTool
    let onDrawTap: () -> Void
    let onTextTap: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Кнопка Draw
            Button(action: onDrawTap) {
                Image(systemName: MarkupTool.draw.iconName)
                    .font(.title2)
                    .foregroundColor(markup == .draw ? .accentColor : .secondary)
            }

            // Кнопка Text
            Button(action: onTextTap) {
                Image(systemName: MarkupTool.text.iconName)
                    .font(.title2)
                    .foregroundColor(markup == .text ? .accentColor : .secondary)
            }
        }
        .controlSize(.large)
        .padding(.horizontal, 8)   
    }
}
```

### TextPreviewArea - Область предпросмотра с поддержкой текста

```swift
import SwiftUI

struct TextPreviewArea: View {
    @ObservedObject var vm: EditorViewModel
    @ObservedObject var textVM: TextOverlayViewModel

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h: CGFloat = {
                if let ui = vm.previewImage {
                    let aspect = ui.size.width / ui.size.height
                    return w / aspect
                } else {
                    return w * 0.6
                }
            }()

            ZStack {
                // Слой с текстовыми элементами
                TextOverlayLayer(textVM: textVM,
                                 enabled: vm.markup == .text)
                    .frame(width: w, height: h)

                // Затемнение + подсказка при размещении
                if vm.markup == .text && textVM.isPlacing {
                    Color.black.opacity(0.4).frame(width: w, height: h)
                    Text("Нажмите, чтобы добавить текст")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(.ultraThinMaterial,
                                    in: RoundedRectangle(cornerRadius: 8))
                        .frame(width: w, height: h, alignment: .center)
                }
            }
            .frame(width: w, height: h)
            .coordinateSpace(name: "canvas")
            .contentShape(Rectangle())

            // Жест тапа для добавления текста
            .gesture(
                TapGesture()
                    .onEnded {
                        guard vm.markup == .text, textVM.isPlacing else { return }

                        let overlap = max(0, vm.keyboardHeight - geo.safeAreaInsets.bottom)

                        textVM.placeCentered(
                            in: CGSize(width: w, height: h),
                            keyboardH: overlap
                        )
                    }
            )

            // Обработка изменения клавиатуры
            .onChange(of: vm.keyboardHeight) { newH in
                let overlap = max(0, newH - geo.safeAreaInsets.bottom)

                textVM.adjustActivePosition(
                    canvas: CGSize(width: w, height: h),
                    keyboardH: overlap
                )
            }
        }
    }
}
```

### TextEditorView - Полное представление для работы с текстом

```swift
import SwiftUI

struct TextEditorView: View {
    @ObservedObject var vm: EditorViewModel
    @ObservedObject var textVM: TextOverlayViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Верхняя панель с кнопками
            HStack(spacing: 16) {
                Spacer(minLength: 0)

                TrailingControls(
                    markup: $vm.markup,
                    onDrawTap: vm.startDraw,
                    onTextTap: vm.startText)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)

            // Область предпросмотра с текстом
            TextPreviewArea(vm: vm, textVM: textVM)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)

        // Toolbar для текстовых инструментов
        .toolbar {
            if vm.markup == .text, textVM.activeID != nil {
                TextToolsToolbar(
                    vm:     textVM,
                    onDone: textVM.finishEditing
                )
            }
        }

        // Обработка смены режима
        .onChange(of: vm.markup) { 
            if vm.markup == .text {
                textVM.enterPlacement()
            } else {
                // из текстового режима ушли — закрываем все поля
                textVM.finishEditing()
            }
        }
    }
}
```

---

## Перечисления

### MarkupTool - Перечисление режимов редактирования

```swift
import SwiftUI

enum MarkupTool: CaseIterable, Identifiable {
    case none
    case draw
    case text

    var id: Self { self }

    var iconName: String {
        switch self {
        case .none:
            return ""
        case .draw:
            return "pencil.tip"
        case .text:
            return "textformat"
        }
    }
}
```

---

## Сервисы

### TextOverlayService - Сервис для наложения текста на изображение

```swift
import Foundation
import UIKit

protocol TextOverlayService {
    func overlay(
        items: [TextItem],
        on data: Data
    ) throws -> Data
}

enum TextOverlayError: Error {
    case invalidData, contextFailed, encodeFailed
}

final class TextOverlayServiceImpl: TextOverlayService {
    func overlay(items: [TextItem], on data: Data) throws -> Data {
        guard let baseImage = UIImage(data: data) else {
            throw TextOverlayError.invalidData
        }
        let size = baseImage.size
        UIGraphicsBeginImageContextWithOptions(size, false, baseImage.scale)
        defer { UIGraphicsEndImageContext() }

        // Рисуем фон
        baseImage.draw(at: .zero)

        // Рисуем каждый текст
        for item in items {
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: item.fontName, size: item.fontSize)
                        ?? UIFont.systemFont(ofSize: item.fontSize),
                .foregroundColor: item.color
            ]
            let ns = NSString(string: item.text)
            let textSize = ns.size(withAttributes: attrs)
            let origin = CGPoint(
                x: item.position.x - textSize.width/2,
                y: item.position.y - textSize.height/2
            )
            ns.draw(at: origin, withAttributes: attrs)
        }

        guard let combined = UIGraphicsGetImageFromCurrentImageContext(),
              let pngData  = combined.pngData() else {
            throw TextOverlayError.encodeFailed
        }
        return pngData
    }
}
```

---

## Интеграция с EditorViewModel

### Расширение EditorViewModel для работы с текстом

```swift
import SwiftUI
import Combine

extension EditorViewModel {
    func startText() {
        markup = .text
        // включаем режим "разместить текст следующий тап"
        textVM.enterPlacement()
    }

    func finishMarkup() {
        markup = .none
        textVM.finishEditing()
    }

    /// Вызывается каждый раз, когда клавиатура меняет высоту
    func updateKeyboard(h: CGFloat) {
        keyboardHeight = h
    }
}
```

### Интеграция в EditorView

```swift
// В EditorView добавляем:
@ObservedObject var textVM: TextOverlayViewModel

// В body добавляем:
TextOverlayLayer(textVM: textVM,
                 enabled: vm.markup == .text)
    .frame(width: w, height: h)

// В toolbar добавляем:
if vm.markup == .text, vm.textVM.activeID != nil {
    TextToolsToolbar(
        vm:     vm.textVM,
        onDone: vm.textVM.finishEditing
    )
}

// Обработка смены режима:
.onChange(of: vm.markup) { 
    if vm.markup == .text {
        vm.textVM.enterPlacement()
    } else {
        vm.textVM.finishEditing()
    }
}
```

---

## Основные функции

### Добавление текста
1. Пользователь нажимает кнопку "Text" в верхней панели
2. Включается режим `isPlacing`
3. Появляется затемнение с подсказкой "Нажмите, чтобы добавить текст"
4. При тапе создается новый `TextItem` в позиции над клавиатурой
5. Автоматически открывается клавиатура для ввода текста

### Редактирование текста
1. Пользователь тапает по существующему тексту
2. Текст переводится в режим редактирования (`isEditing = true`)
3. Появляется панель инструментов над клавиатурой
4. Можно изменить цвет, размер или удалить текст

### Форматирование
- **Цвет**: ColorPicker в панели инструментов
- **Размер**: Stepper с диапазоном 10-72 pt
- **Удаление**: кнопка корзины в панели инструментов

### Позиционирование
- Текст автоматически позиционируется над клавиатурой
- При изменении высоты клавиатуры позиция корректируется
- Поддержка многострочного текста с центрированием

---

## Зависимости

```swift
import SwiftUI
import Combine
import UIKit
```

---

## Требования

- iOS 15.0+
- Swift 5.7+
- Xcode 14.0+ 