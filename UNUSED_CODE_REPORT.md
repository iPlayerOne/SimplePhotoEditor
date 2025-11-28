# Отчёт о неиспользуемом коде

## 🔴 Полностью неиспользуемые модели

1. **`Core/Models/Stroke.swift`** - Определена структура `Stroke`, но нигде не используется в коде
2. **`Core/Models/Photo.swift`** - Определена структура `Photo`, но нигде не используется в коде

## 🔴 Полностью закомментированные файлы

3. **`Core/Services/Processing/PreviewRenderService.swift`** - Весь файл закомментирован, не используется
4. **`Core/State/AppState.swift`** - Весь файл закомментирован, не используется

## 🔴 Неиспользуемые сервисы

5. **`Core/Services/Processing/DrawService.swift`** - Протокол `DrawingService` и класс `DrawingServiceImpl` определены, но нигде не используются (используется PencilKit напрямую через `OverlayRenderService`)
6. **`Core/Services/Processing/TextOverlay.swift`** - Протокол `TextOverlayService` и класс `TextOverlayServiceImpl` определены, но нигде не используются (текст рендерится через `OverlayRenderService`)

## 🔴 Неиспользуемые компоненты UI

7. **`Features/Editor/Components/FilterTools/FilterPreviewImage.swift:39-50`** - Структура `FilteredImage` определена, но не используется (используется только `FilteredImageView`)

## 🔴 Неиспользуемые модификаторы

8. **`Core/Utilities/Modifiers/Draggable.swift`** - Модификатор определен, но `.draggable()` нигде не вызывается
9. **`Core/Utilities/Modifiers/Liftable.swift`** - Модификатор определен, но `.liftable()` нигде не вызывается  
10. **`Core/Utilities/Modifiers/ShimmerModifier.swift`** - Модификатор определен, но `.shimmer()` нигде не вызывается
11. **`Core/Utilities/Modifiers/PanelSurface.swift`** - Модификатор определен, но нет расширения View и нигде не используется

## 🔴 Неиспользуемые импорты

12. **`Features/Editor/EditorView.swift`** - Импорт `import CoreImage` не используется
13. **`Features/Editor/ViewModels/EditorViewModel.swift`** - Импорт `import UniformTypeIdentifiers` не используется (loadTransferable работает без него)

## 🔴 Неиспользуемые функции

14. **`Core/Services/Auth/FirebaseAuthService.swift:46-48`** - Приватная функция `_peripheryProbe()` с явным комментарием "never used"

## 📊 Итого

- **14 элементов** неиспользуемого кода
- **4 файла** полностью неиспользуемых
- **2 модели** неиспользуемых
- **2 сервиса** неиспользуемых
- **4 модификатора** неиспользуемых
- **2 импорта** неиспользуемых
- **1 функция** неиспользуемая

## 💡 Рекомендации

1. Удалить полностью закомментированные файлы
2. Удалить неиспользуемые модели и сервисы
3. Удалить неиспользуемые модификаторы или реализовать их использование
4. Удалить неиспользуемые импорты
5. Удалить тестовые функции

