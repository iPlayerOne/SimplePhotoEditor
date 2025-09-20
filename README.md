# SimplePhotoEditor

Приложение для iOS (SwiftUI, MVVM) с авторизацией (Email/Google) и простым фоторедактором: кадрирование/трансформации, фильтры Core Image, рисование PencilKit, текстовые слои и экспорт.

## Быстрый старт

1) Откройте `SimplePhotoEditor.xcodeproj` в Xcode.
2) Через SPM установите зависимости (если Xcode предложит).
3) Создайте проект в Firebase и скачайте `GoogleService-Info.plist` в корень таргета.
4) Включите Sign-In with Google в Firebase, добавьте URL Schemes из `GoogleService-Info.plist` в `Info.plist` таргета.
5) Запустите на iOS 15+ симуляторе или устройстве.

## Возможности

- **Авторизация**: email/пароль, Google, сброс пароля
- **Редактор**: фильтры Core Image, поворот/зеркалирование, PencilKit-рисование, текстовые слои, экспорт/ShareSheet
- **Производительность**: кеш превью фильтров, оптимизированный пайплайн CI, безопасное декодирование UIImage

## Архитектура

- **UI**: SwiftUI, feature-модули `Auth` и `Editor`
- **Состояние**: `SessionStore` (наблюдение за auth), `EditorViewModel` и `TextOverlayViewModel`
- **Сервисы**: `Auth`, `Processing` (фильтры, пайплайн, композиция, трансформации), `Export`, `Camera`
- **Внедрение зависимостей**: `DependencyContainer` в `App/`

## Структура проекта

```
SimplePhotoEditor/
├── App/
│   ├── AppDelegate.swift
│   ├── AppConfig.swift
│   ├── DependencyContainer.swift
│   ├── Info.plist
│   └── SimplePhotoEditorApp.swift
├── Assets.xcassets/
├── Core/
│   ├── Models/
│   │   ├── Filter.swift
│   │   ├── Photo.swift
│   │   ├── ShareItem.swift
│   │   ├── Stroke.swift
│   │   ├── TextItem.swift
│   │   └── User.swift
│   ├── Services/
│   │   ├── Auth/
│   │   │   ├── AuthError.swift
│   │   │   └── FirebaseAuthService.swift
│   │   ├── Camera/
│   │   │   └── CameraService.swift
│   │   ├── Export/
│   │   │   └── ExportService.swift
│   │   └── Processing/
│   │       ├── CIContextPool.swift
│   │       ├── CIHelpers.swift
│   │       ├── DrawService.swift
│   │       ├── FilterProvider.swift
│   │       ├── FilterService.swift
│   │       ├── ImageComposeService.swift
│   │       ├── ImageDecodeService.swift
│   │       ├── ImagePipeline.swift
│   │       ├── OverlayRenderService.swift
│   │       ├── PhotoProcessingService.swift
│   │       ├── PreviewRenderService.swift
│   │       ├── TextOverlay.swift
│   │       └── TransformService.swift
│   ├── State/
│   │   ├── AppState.swift
│   │   └── SessionStore.swift
│   └── Utilities/
│       ├── CanvasMetrics.swift
│       ├── Extensions/
│       │   ├── Color+UIColor.swift
│       │   ├── Image+Filter.swift
│       │   └── String+CamelCase.swift
│       ├── FilterWidthKey.swift
│       ├── GeometryHelper.swift
│       ├── KeyboardObserver.swift
│       ├── Modifiers/
│       │   ├── AlertModifier.swift
│       │   ├── Draggable.swift
│       │   ├── IconStyle.swift
│       │   ├── Liftable.swift
│       │   ├── PanelSurface.swift
│       │   ├── ShimmerModifier.swift
│       │   └── UnderlineModifier.swift
│       ├── ShareSheet.swift
│       └── UIImage+SafeDecode.swift
├── Features/
│   ├── Auth/
│   │   ├── Components/
│   │   │   ├── AuthButtonStyle.swift
│   │   │   ├── AuthFieldModifier.swift
│   │   │   ├── AuthTextField.swift
│   │   │   └── PrimaryActionButton.swift
│   │   ├── ViewModels/
│   │   │   ├── LoginViewModel.swift
│   │   │   ├── RegistrationViewModel.swift
│   │   │   └── ResetPasswordViewModel.swift
│   │   ├── AuthRoute.swift
│   │   ├── AuthRouter.swift
│   │   ├── AuthStackView.swift
│   │   ├── GoogleSignInCoordinator.swift
│   │   ├── LoginView.swift
│   │   ├── RegistrationView.swift
│   │   └── ResetPasswordView.swift
│   └── Editor/
│       ├── CameraPicker.swift
│       ├── Components/
│       │   ├── FilterTools/
│       │   │   └── FilterPreviewImage.swift
│       │   ├── KeyboardAccessory/
│       │   │   ├── AccessoryHostingController.swift
│       │   │   └── KeyboardAccessory.swift
│       │   ├── Preview/
│       │   │   ├── CanvasLayer.swift
│       │   │   ├── PencilCanvasView.swift
│       │   │   ├── PhotoLayer.swift
│       │   │   ├── PreviewArea.swift
│       │   │   ├── TextItemView.swift
│       │   │   ├── TextOverlayLayer.swift
│       │   │   └── ZoomableView.swift
│       │   ├── Tab/
│       │   │   ├── ModeButton.swift
│       │   │   └── ModeTabBar.swift
│       │   └── Tools/
│       │       ├── DrawToolsPanel.swift
│       │       ├── EditorTopBar.swift
│       │       ├── FilterPreviewCache.swift
│       │       ├── FilterToolsPanel.swift
│       │       ├── TextToolsToolbar.swift
│       │       ├── ToolsPanel.swift
│       │       └── TopToolControls.swift
│       ├── EditModeSelector.swift
│       ├── EditorNavigationBar.swift
│       ├── EditorStates.swift
│       ├── EditorView.swift
│       ├── ImageSourcePicker.swift
│       ├── Models/
│       │   └── EditorMode.swift
│       └── ViewModels/
│           ├── EditorViewModel.swift
│           └── TextOverlayViewModel.swift
├── Navigation/
│   └── RootView.swift
├── GoogleService-Info.plist
└── README.md
```

## Основные компоненты

### App/
- **AppDelegate.swift** — делегат приложения, инициализация сервисов (Firebase, GoogleSignIn)
- **AppConfig.swift** — конфигурация приложения (например, clientID для Google)
- **DependencyContainer.swift** — DI-контейнер, собирает зависимости для фич
- **SimplePhotoEditorApp.swift** — точка входа, инициализация сессии и зависимостей
- **Info.plist** — настройки приложения

### Core/Services/
- **Auth/** — сервисы аутентификации через Firebase
- **Processing/** — обработка изображений, фильтры, трансформации, композиция
- **Export/** — экспорт и сохранение в фотопоток
- **Camera/** — работа с камерой устройства

### Core/State/
- **SessionStore.swift** — хранит состояние сессии пользователя, подписка на изменения
- **AppState.swift** — общее состояние приложения

### Features/Auth/
- **Components/** — UI-компоненты для форм и кнопок
- **ViewModels/** — view model'и для логики авторизации, регистрации, сброса пароля
- **AuthStackView.swift** — корневой стек для auth flow
- **LoginView.swift** — экран входа
- **RegistrationView.swift** — экран регистрации
- **ResetPasswordView.swift** — восстановление пароля
- **GoogleSignInCoordinator.swift** — интеграция с Google Sign-In

### Features/Editor/
- **Components/** — UI-компоненты редактора (Preview, Tools, Tab и др.)
- **Models/** — модели, специфичные для редактора
- **ViewModels/** — view model'и для редактора и текстовых слоёв
- **EditorView.swift** — основной экран редактора
- **CameraPicker.swift** — выбор камеры
- **ImageSourcePicker.swift** — выбор источника изображения

## Флоу авторизации

### 1. Инициализация приложения
1. **Запуск приложения** → `SimplePhotoEditorApp.init()`
2. **Настройка Firebase** → `FirebaseApp.configure()`
3. **Создание сервисов**:
   - `FirebaseAuthService()` — основной сервис авторизации
   - `SessionStore(authService)` — управление состоянием сессии
   - `AppDependencyContainer(authService)` — DI-контейнер
4. **Проверка текущего пользователя** → `Auth.auth().currentUser`

### 2. Определение состояния авторизации
1. **Синхронная проверка** → `SessionStore.init()` проверяет `Auth.auth().currentUser != nil`
2. **Асинхронное наблюдение** → подписка на `authService.authStatePublisher`
3. **Установка флагов**:
   - `isAuthenticated` — статус авторизации
   - `didFinishChecking` — завершена ли проверка состояния

### 3. Навигация по состояниям (RootView)
```
if !session.didFinishChecking {
    ProgressView() // Показываем загрузку
}
else if session.isAuthenticated {
    EditorView() // Переход в редактор
}
else {
    AuthStackView() // Показываем формы авторизации
}
```

### 4. Flow входа через Email/Пароль
1. **Пользователь вводит данные** → `LoginView`
2. **Валидация** → `LoginViewModel.canSignIn` проверяет email и пароль (≥6 символов)
3. **Вызов API** → `authService.signIn(email, password)`
4. **Обработка результата**:
   - ✅ **Успех** → `SessionStore.authStatePublisher` получает пользователя → переход в `EditorView`
   - ❌ **Ошибка** → показ `AuthError` через `.alertLocalizedError`

### 5. Flow входа через Google
1. **Нажатие кнопки Google** → `GoogleSignInButton`
2. **Инициализация координатора** → `GoogleSignInCoordinatorImpl`
3. **Вызов Google SDK** → `GIDSignIn.sharedInstance.signIn()`
4. **Получение токенов** → `idToken` и `accessToken`
5. **Авторизация в Firebase** → `authService.signInWithGoogle(idToken, accessToken)`
6. **Результат** → аналогично email/паролю

### 6. Flow регистрации
1. **Переход на регистрацию** → `AuthRouter.path.append(.signUp)`
2. **Ввод данных** → `RegistrationView` с полями email, пароль, подтверждение пароля
3. **Валидация** → `RegistrationViewModel.canRegister` проверяет:
   - Email содержит "@" и "."
   - Пароль ≥ 6 символов
   - Пароли совпадают
4. **Создание аккаунта** → `authService.register(email, password)`
5. **Отправка верификации** → `result.user.sendEmailVerification()`
6. **Уведомление** → показ алерта "Письмо отправлено"

### 7. Flow восстановления пароля
1. **Переход на сброс** → `AuthRouter.path.append(.resetPassword)`
2. **Ввод email** → `ResetPasswordView`
3. **Валидация** → `ResetPasswordViewModel.canReset` проверяет email
4. **Отправка письма** → `authService.resetPassword(email)`
5. **Уведомление** → показ алерта "Проверьте почту"

### 8. Flow выхода
1. **Нажатие кнопки выхода** → `onLogout()` колбэк
2. **Выход из Firebase** → `authService.signOut()`
3. **Обновление состояния** → `SessionStore.authStatePublisher` получает `nil`
4. **Переход к авторизации** → показ `AuthStackView`

## Флоу работы редактора

### 1. Инициализация редактора
1. **Переход в редактор** → `EditorView` загружается после успешной авторизации
2. **Создание ViewModels**:
   - `EditorViewModel` — основная логика редактора
   - `TextOverlayViewModel` — управление текстовыми слоями
   - `KeyboardObserver` — отслеживание клавиатуры
   - `FilterPreviewCache` — кеширование превью фильтров
3. **Инициализация состояния** → все инструменты в режиме `.none`

### 2. Flow выбора изображения
1. **Нажатие кнопки "+"** → `showSourceDialog = true`
2. **Выбор источника** → `ImageSourcePicker` показывает диалог:
   - "Камера" → `CameraPicker` (UIImagePickerController)
   - "Галерея" → `PhotosPicker` (PhotosUI)
3. **Получение данных**:
   - **Камера** → `CameraPicker.onImagePicked(UIImage)` → JPEG data
   - **Галерея** → `PhotosPicker.loadTransferable(Data.self)` → исходные данные
4. **Обновление модели** → `vm.inputData = data`

### 3. Flow обработки изображения
1. **Получение данных** → `EditorViewModel.inputData` обновляется
2. **Декодирование** → `ImageDecodeService.downsample()` для превью (600px)
3. **Применение фильтров** → `PreviewRenderService.renderPreview()` с downscale 0.25
4. **Обновление UI** → `previewImage` обновляется через `@Published`

### 4. Flow работы с фильтрами
1. **Подготовка превью** → `FilterPreviewCache.preparePreviews()` для всех фильтров
2. **Отображение панели** → `FilterToolsPanel` показывает горизонтальный скролл
3. **Выбор фильтра** → `FilterPreviewImage.onTap()` → `selectedFilter = filter`
4. **Обновление превью** → `EditorViewModel` автоматически применяет фильтр
5. **Кеширование** → превью сохраняются в `FilterPreviewCache` для быстрого доступа

### 5. Flow рисования (PencilKit)
1. **Активация режима** → `ToolsPanel` → кнопка "pencil.tip" → `vm.startDraw()`
2. **Переключение режима** → `vm.markup = .draw`
3. **Отображение холста** → `PencilCanvasView` становится видимым
4. **Настройка инструментов** → `DrawToolsPanel`:
   - **Цвет** → `ColorPicker` → `PKInkingTool(.pen, color: newColor)`
   - **Толщина** → `Slider` → `PKInkingTool(.pen, width: newWidth)`
   - **Ластик** → `isErasing.toggle()` → `PKInkingTool(.eraser)`
5. **Очистка** → кнопка "trash" → `drawing = PKDrawing()`

### 6. Flow работы с текстом
1. **Активация режима** → `ToolsPanel` → кнопка "textformat" → `vm.startText()`
2. **Переключение режима** → `vm.markup = .text` → `textVM.enterPlacement()`
3. **Ожидание клавиатуры** → `waitForKeyboard = true`
4. **Появление клавиатуры** → `KeyboardObserver` → `textVM.keyboardDidChange()`
5. **Размещение текста** → `placeText()` создает `TextItem` в центре над клавиатурой
6. **Редактирование** → `TextItemView.onTapGesture()` → `textVM.setActive(editing: true)`
7. **Настройка текста** → `TextToolsToolbar`:
   - **Цвет** → `ColorPicker` → `textVM.apply(.color(newColor))`
   - **Размер** → `Stepper` → `textVM.apply(.size(newSize))`
8. **Завершение** → кнопка "Готово" → `textVM.finishEditing()`
9. **Перемещение** → `TextItemView.draggable()` позволяет перетаскивать текст

### 7. Flow трансформаций
1. **Поворот** → `TopToolControls` → кнопка "rotate.right" → `vm.rotationCount = (vm.rotationCount + 1) % 4`
2. **Отражение** → кнопка "flip.horizontal" → `vm.isFlippedHorizontally.toggle()`
3. **Применение** → изменения автоматически отражаются в превью через `EditorViewModel`

### 8. Flow экспорта и шаринга
1. **Экспорт в галерею** → кнопка "square.and.arrow.up" → `vm.share(drawingOverlay: drawing)`
2. **Рендеринг финального изображения** → `renderFinalImage()`:
   - Применение фильтра → `FilterService.apply()`
   - Наложение слоев → `OverlayRenderService.apply(drawing, text)`
   - Поворот → `TransformService.rotate90()`
   - Отражение → `TransformService.flipHorizontal()`
3. **Создание ShareItem** → `ShareItem(image: UIImage)`
4. **Показ ShareSheet** → `UIActivityViewController` с возможностью:
   - Сохранения в фотопоток
   - Отправки в другие приложения
   - Копирования в буфер обмена

## Функциональность редактора

### 1. Работа с изображениями
- Загрузка изображений из галереи через PhotosUI
- Съемка фотографий через камеру
- Предварительный просмотр с оптимизацией производительности
- Экспорт в различные форматы
- Сохранение в фотопоток пользователя

### 2. Инструменты рисования (PencilKit)
- Рисование с настраиваемой толщиной линии
- Выбор цвета
- Режим ластика
- Очистка всего рисунка
- Поддержка Apple Pencil

### 3. Работа с текстом
- Добавление текстовых слоев в фиксированной позиции над клавиатурой
- Настройка размера шрифта через степпер
- Выбор цвета текста через ColorPicker
- Перемещение текста по холсту после ввода
- Редактирование существующего текста по тапу
- Удаление текстовых слоев
- Кастомный тулбар над клавиатурой с инструментами форматирования

### 4. Фильтры и трансформации
- Применение фильтров Core Image
- Поворот изображения
- Отражение по горизонтали
- Предварительный просмотр эффектов
- Оптимизированная обработка изображений

### 5. Система авторизации
- Вход через email
- Авторизация через Google
- Регистрация новых пользователей
- Восстановление пароля
- Валидация данных

## Установка и запуск

1. Клонируйте репозиторий
2. Установите зависимости через Swift Package Manager
3. Настройте Firebase проект и добавьте `GoogleService-Info.plist`
4. Запустите проект

## Требования

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

## Исходный код файлов App

### AppDelegate.swift
```swift
import UIKit
import FirebaseCore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    // добавили этот метод
    func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // Если вы хотите инициализировать Firebase здесь, то не забудьте вызвать configure()
        // FirebaseApp.configure()
        return true
    }

    func application(
      _ app: UIApplication,
      open url: URL,
      options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        GIDSignIn.sharedInstance.handle(url)
    }
}
```

### AppConfig.swift
```swift
import FirebaseCore

enum AppConfig {
    static func setupFirebase() {
        FirebaseApp.configure()
    }

    static var googleClientID: String {
        guard let id = FirebaseApp.app()?.options.clientID else {
            preconditionFailure("GoogleClientID не настроен в GoogleService‑Info.plist")
        }
        return id
    }
}
```

### DependencyContainer.swift
```swift
// AppDependencyContainer.swift
import Foundation

@MainActor
final class AppDependencyContainer {
    private let authService: AuthService

    init(authService: AuthService = FirebaseAuthService()) {
        self.authService = authService
    }

    func makeGoogleSignInCoordinator() -> GoogleSignInCoordinator {
        GoogleSignInCoordinatorImpl(clientID: AppConfig.googleClientID)
    }

    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(
            authService: authService,
            googleCoordinator: makeGoogleSignInCoordinator()
        )
    }

    func makeRegistrationViewModel() -> RegistrationViewModel {
        RegistrationViewModel(authService: authService)
    }

    func makeResetPasswordViewModel() -> ResetPasswordViewModel {
        ResetPasswordViewModel(authService: authService)
    }

    func makeEditorViewModel() -> EditorViewModel {
        let transformService      = TransformServiceImpl()
        let filterService         = FilterServiceImpl()
        let overlayService        = OverlayRenderServiceImpl()
        let imageDecodeService    = ImageDecodeServiceImpl()
        let previewService        = PreviewRenderServiceImpl()
        let exportService         = ExportServiceImpl()

        return EditorViewModel(
            transformService:   transformService,
            filterService:      filterService,
            exportService:      exportService,
            overlayService:     overlayService,
            previewService:     previewService
        )
    }
}
```

### SimplePhotoEditorApp.swift
```swift
// App/SimplePhotoEditorApp.swift

import SwiftUI
import FirebaseCore

@main
struct SimplePhotoEditorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var session: SessionStore
    private let container: AppDependencyContainer

    init() {
        // --- ОБЯЗАТЕЛЬНО первым делом на старте ---
        FirebaseApp.configure()

        // Создаём единый инстанс AuthService
        let authService = FirebaseAuthService()
        // Передаём его и в SessionStore, и в DI-контейнер
        let sessionStore = SessionStore(authService: authService)
        _session = StateObject(wrappedValue: sessionStore)
        container = AppDependencyContainer(authService: authService)
    }

    var body: some Scene {
        WindowGroup {
            RootView(
                container: container,
                onLogout:  { session.logout() }
            )
            .environmentObject(session)
        }
    }
}
```

### Info.plist
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>

    <key>NSCameraUsageDescription</key>
    <string>Нужен доступ к камере, чтобы делать снимки</string>
    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>Приложение сохраняет отредактированные фото в вашу фотоплёнку.</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>Приложение использует фотогалерею, чтобы вы могли выбрать изображение для редактирования.</string>

    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
            <key>CFBundleURLName</key>
            <string>GoogleSignIn</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>com.googleusercontent.apps.410428643138-pm5fh2l966m0mnl21145cpnqcjb7gtac</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
```

---

## Исходный код Core/Models

### Photo.swift
```swift
import Foundation

struct Photo: Identifiable {
    let id: UUID = UUID()
    let imageData: Data
    let creationDate: Date
}
```

### Filter.swift
```swift
import Foundation

struct Filter: Identifiable, Equatable {
    let id: UUID
    let name: String
    let filterName: String

    static var none: Filter {
        Filter(id: UUID(), name: "Нет", filterName: "")
    }
    var isNone: Bool { filterName.isEmpty }

    init(id: UUID = UUID(), name: String, filterName: String) {
        self.id = id
        self.name = name
        self.filterName = filterName
    }
}
```

### Stroke.swift
```swift
import SwiftUI

struct Stroke: Identifiable {
    let id: UUID = UUID()
    var points: [CGPoint]
    let lineWidth: CGFloat
    let color: Color
}
```

### TextItem.swift
```swift
import SwiftUI

struct TextItem: Identifiable {
    let id = UUID()

    var text:      String
    var fontName:  String
    var fontSize:  CGFloat
    var color:     Color
    var position:  CGPoint
    var parkedPosition: CGPoint?

    var isEditing  = false
}
```

### ShareItem.swift
```swift
import UniformTypeIdentifiers
import SwiftUI

struct ShareItem: Identifiable, Equatable {
    let id: UUID = UUID()
    let image: UIImage
    static func == (lhs: ShareItem, rhs: ShareItem) -> Bool {
        lhs.id == rhs.id
    }
}
```

### User.swift
```swift
struct User {
    let uid: String
    let email: String
}
```

---

## Исходный код Core/Services/Auth

### AuthError.swift
```swift
import Foundation

enum AuthError: Error, Identifiable {
    // MARK: - Email / Password
    case emailAlreadyInUse
    case invalidEmailFormat
    case userNotFound
    case wrongPassword
    case weakPassword
    case userDisabled
    case tooManyRequests
    
    // MARK: Google
    case accountExistsWithDifferentCredential
    case credentialAlreadyInUse
    case invalidCredential
    case popupClosedByUser
    case operationNotAllowed
    
    case networkError(underlying: Error)
    case unknown
    
    var id: String { localizedDescription }

    var localizedDescription: String {
        switch self {
                
        case .emailAlreadyInUse:
            return "Этот email уже зарегистрирован."
        case .invalidEmailFormat:
            return "Неверный формат email."
        case .userNotFound:
            return "Пользователь не найден."
        case .wrongPassword:
            return "Неверный пароль."
        case .weakPassword:
            return "Пароль слишком простой (минимум 6 символов)."
        case .userDisabled:
            return "Аккаунт отключён. Обратитесь в поддержку."
        case .tooManyRequests:
            return "Слишком много попыток. Попробуйте позже."
                
        case .accountExistsWithDifferentCredential:
            return "Этот email привязан к другому провайдеру."
        case .credentialAlreadyInUse:
            return "Учётные данные уже используются другим аккаунтом."
        case .invalidCredential:
            return "Неверные или устаревшие учётные данные."
        case .popupClosedByUser:
            return "Вход отменён пользователем."
        case .operationNotAllowed:
            return "Вход через Google отключён администратором."

        case .networkError:
            return "Проблемы с сетью. Проверьте подключение."
        case .unknown:
            return "Произошла неизвестная ошибка. Попробуйте снова."
        }
    }
}

extension AuthError: LocalizedError {
    var errorDescription: String? { localizedDescription }
}
```

### FirebaseAuthService.swift
```swift
import FirebaseAuth
import Combine

protocol AuthService {
  func signIn(email: String, password: String) async throws -> User
  func register(email: String, password: String) async throws -> User
  func resetPassword(email: String) async throws
  func signOut() throws
  func signInWithGoogle(idToken: String, accessToken: String) async throws -> User
  var authStatePublisher: AnyPublisher<User?, Never> { get }
}

final class FirebaseAuthService: AuthService {
    private let subject: CurrentValueSubject<User?, Never>
    var authStatePublisher: AnyPublisher<User?, Never> {
        subject.eraseToAnyPublisher()
    }

    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        let initialUser: User? = {
            guard let fbUser = Auth.auth().currentUser,
                  let mail   = fbUser.email
            else { return nil }
            return User(uid: fbUser.uid, email: mail)
        }()

        subject = CurrentValueSubject<User?, Never>(initialUser)

        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, fbUser in
            let updated: User? = {
                guard let u = fbUser, let mail = u.email else { return nil }
                return User(uid: u.uid, email: mail)
            }()
            self?.subject.send(updated)
        }
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func signIn(email: String, password: String) async throws -> User {
        do {
            let result = try await Auth.auth().signIn(
                withEmail: email,
                password: password
            )
            guard let mail = result.user.email else {
                throw AuthError.unknown
            }
            return User(uid: result.user.uid, email: mail)
        } catch {
            let ns = error as NSError
            if let code = AuthErrorCode(rawValue: ns.code) {
                switch code {
                case .wrongPassword:
                    throw AuthError.wrongPassword
                case .userNotFound:
                    throw AuthError.userNotFound
                case .networkError:
                    throw AuthError.networkError(underlying: ns)
                default:
                    throw AuthError.networkError(underlying: ns)
                }
            }
            throw AuthError.networkError(underlying: ns)
        }
    }

    func register(email: String, password: String) async throws -> User {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            try await result.user.sendEmailVerification()
            guard let mail = result.user.email else {
                throw AuthError.unknown
            }
            return User(uid: result.user.uid, email: mail)
        } catch {
            let ns = error as NSError
            if let code = AuthErrorCode(rawValue: ns.code) {
                switch code {
                case .emailAlreadyInUse:
                    throw AuthError.emailAlreadyInUse
                case .invalidEmail:
                    throw AuthError.invalidEmailFormat
                case .weakPassword:
                    throw AuthError.weakPassword
                case .operationNotAllowed:
                    throw AuthError.operationNotAllowed
                default:
                    throw AuthError.networkError(underlying: ns)
                }
            }
            throw AuthError.networkError(underlying: ns)
        }
    }

    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }

    func signOut() throws {
        try Auth.auth().signOut()
    }

    func signInWithGoogle(idToken: String, accessToken: String) async throws -> User {
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: accessToken
        )
        let result = try await Auth.auth().signIn(with: credential)
        guard let mail = result.user.email else {
            throw AuthError.unknown
        }
        return User(uid: result.user.uid, email: mail)
    }
}
```

---

## Исходный код Core/State

### SessionStore.swift
```swift
import Foundation
import Combine
import FirebaseAuth

@MainActor
final class SessionStore: ObservableObject {
    @Published var isAuthenticated: Bool
    @Published var didFinishChecking = false

    private let authService: AuthService
    private var cancellable: AnyCancellable?

    init(authService: AuthService = FirebaseAuthService()) {
        self.authService = authService
        // синхронный старт
        let initial = Auth.auth().currentUser != nil
        self.isAuthenticated = initial

        // последующий контроль
        cancellable = authService.authStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.isAuthenticated     = (user != nil)
                self?.didFinishChecking   = true
            }
    }

    func logout() {
        try? authService.signOut()
    }
}
```

### AppState.swift
```swift
import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?

    private var cancellables = Set<AnyCancellable>()
    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
        authService.authStatePublisher
//            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.currentUser     = user
                self?.isAuthenticated = (user != nil)
            }
            .store(in: &cancellables)
    }

    func logout() {
        do {
            try authService.signOut()
        } catch {
            print("Logout failed:", error)
        }
    }
}
```

---

## Исходный код Core/Services/Processing

### OverlayRenderService.swift
```swift
import UIKit
import PencilKit
import UniformTypeIdentifiers
import ImageIO

protocol OverlayRenderService {
    func apply(drawing: PKDrawing?, text: [TextItem]?, to data: Data) throws -> Data
}

enum OverlayRenderError: Error {
    case invalidBase
    case encodeFailed
}

final class OverlayRenderServiceImpl: OverlayRenderService {
    
    func apply(drawing: PKDrawing?, text: [TextItem]?, to data: Data) throws -> Data {
        guard let base = UIImage(data: data) else {
            throw OverlayRenderError.invalidBase
        }
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = base.scale
        format.opaque = true
        
        let size = base.size
        let rect = CGRect(origin: .zero, size: size)
        
        let rendered = UIGraphicsImageRenderer(size: size, format: format).image { _ in
            base.draw(in: rect)
            
            if let drawing = drawing {
                let overlay = drawing.image(from: rect, scale: base.scale)
                overlay.draw(in: rect)
            }
            
            if let items = text {
                for item in items {
                    let attrs: [NSAttributedString.Key: Any] = [
                        .font : UIFont(name: item.fontName, size: item.fontSize)
                        ?? .systemFont(ofSize: item.fontSize),
                        .foregroundColor: item.color.uiColor
                    ]
                    
                    (item.text as NSString).draw(
                        at: CGPoint(x: item.position.x, y: item.position.y),
                        withAttributes: attrs
                    )
                }
            }
        }
        
        guard let mergedCG = rendered.cgImage else {
            throw OverlayRenderError.encodeFailed
        }
        
        let out = NSMutableData()
        guard let dst = CGImageDestinationCreateWithData(
            out,
            UTType.jpeg.identifier as CFString,
            1,
            nil
        ) else {
            throw OverlayRenderError.encodeFailed
        }
        let opts = [kCGImageDestinationLossyCompressionQuality: 0.9] as CFDictionary
        CGImageDestinationAddImage(dst, mergedCG, opts)
        CGImageDestinationFinalize(dst)
        return out as Data
    }
}
```

### FilterService.swift
```swift
import UIKit
import CoreImage

protocol FilterService {
    func apply(filterName: String, to data: Data, downscaleFactor: CGFloat) throws -> Data
}

enum FilterError: Error { case invalidData, renderFailed }

final class FilterServiceImpl: FilterService {

    func apply(filterName: String, to data: Data, downscaleFactor: CGFloat = 1.0) throws -> Data {

        guard var ci = CIImage(data: data) else { throw FilterError.invalidData }

        if downscaleFactor < 0.999,
           let lanczos = CIFilter(name: "CILanczosScaleTransform") {
            lanczos.setValue(ci,                forKey: kCIInputImageKey)
            lanczos.setValue(downscaleFactor,   forKey: kCIInputScaleKey)
            lanczos.setValue(1.0,               forKey: kCIInputAspectRatioKey)
            ci = lanczos.outputImage ?? ci
        }

        if !filterName.isEmpty,
           let fx = CIFilter(name: filterName) {
            fx.setValue(ci, forKey: kCIInputImageKey)
            ci = fx.outputImage ?? ci
        }

        
        guard let cg = CIContextPool.shared.createCGImage(ci, from: ci.extent)
        else { throw FilterError.renderFailed }
        
        guard let jpeg = UIImage(cgImage: cg).jpegData(compressionQuality: 0.9) else {
            throw FilterError.renderFailed
        }
        return jpeg
    }
}
```

### TransformService.swift
```swift
import UIKit
import CoreImage
import CoreGraphics

protocol TransformService {
    func rotate90(data: Data, times: Int) throws -> Data
    func flipHorizontal(data: Data) throws -> Data
}

enum TransformError: Error {
    case invalidData, renderFailed, encodeFailed
}

final class TransformServiceImpl: TransformService {
    private let ctx = CIContext()

    func rotate90(data: Data, times: Int) throws -> Data {
        guard let ci = CIImage(data: data) else { throw TransformError.invalidData }
        let angle = CGFloat(times % 4) * .pi/2
        let rotated = ci.transformed(by: .init(rotationAngle: angle))
        return try render(ci: rotated)
    }

    func flipHorizontal(data: Data) throws -> Data {
        guard let ci = CIImage(data: data) else { throw TransformError.invalidData }
        let flipped = ci
            .transformed(by: .init(scaleX: -1, y: 1))
            .transformed(by: .init(translationX: -ci.extent.width, y: 0))
        return try render(ci: flipped)
    }

    // helper
    private func render(ci: CIImage) throws -> Data {
        guard let cg = ctx.createCGImage(ci, from: ci.extent),
              let out = UIImage(cgImage: cg).jpegData(compressionQuality: 1)
        else { throw TransformError.renderFailed }
        return out
    }
}
```

### CIContextPool.swift
```swift
import CoreImage

enum CIContextPool {
    static let shared: CIContext = {
        let opts: [CIContextOption: Any] = [.priorityRequestLow: true]
        return CIContext(options: opts)
    }()
}
```

---

## Исходный код Features/Auth

### LoginView.swift
```swift
// Features/Auth/LoginView.swift

import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    // MARK: – Навигация внутри Auth
    @EnvironmentObject private var authRouter: AuthRouter

    // MARK: – ViewModel
    @StateObject private var vm: LoginViewModel

    // MARK: – Google Sign-In Coordinator
    let googleCoordinator: GoogleSignInCoordinator

    /// Колбэк, вызываемый после успешного логина (чтобы поднять флаг в RootView)
    let onSuccess: () -> Void

    init(
        vm: LoginViewModel,
        googleCoordinator: GoogleSignInCoordinator,
        onSuccess: @escaping () -> Void
    ) {
        _vm = StateObject(wrappedValue: vm)
        self.googleCoordinator = googleCoordinator
        self.onSuccess = onSuccess
    }

    var body: some View {
        VStack(spacing: 32) {
            Text("Welcome Back")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(spacing: 16) {
                AuthTextField(
                    placeholder: "Email",
                    text: $vm.email,
                    keyboard: .emailAddress
                )
                AuthTextField(
                    placeholder: "Password (min 6)",
                    text: $vm.password,
                    isSecure: true
                )
            }

            // MARK: – Кнопки действий
            VStack(spacing: 16) {
                PrimaryActionButton(
                    title: "Sign In",
                    enabled: vm.canSignIn
                ) {
                    Task {
                        await vm.login()
                        if vm.error == nil {
                            onSuccess()
                        }
                    }
                }

                GoogleSignInButton {
                    Task {
                        do {
                            let (idToken, accessToken) = try await
                                googleCoordinator.signIn()
                            await vm.loginWithGoogle(
                                idToken:     idToken,
                                accessToken: accessToken
                            )
                            if vm.error == nil {
                                onSuccess()
                            }
                        } catch {
                            // отмена или ошибки обработать при необходимости
                        }
                    }
                }
                .frame(height: 44)
                .cornerRadius(8)
                .disabled(vm.isLoading)
            }

            // MARK: – Индикатор загрузки
            if vm.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }

            // MARK: – Навигация Sign Up / Reset Password
            HStack {
                Button("Sign Up") {
                    authRouter.path.append(.signUp)
                }
                Spacer()
                Button("Forgot Password?") {
                    authRouter.path.append(.resetPassword)
                }
            }
            .font(.footnote)
            .foregroundColor(.secondary)

            Spacer()
        }
        .padding(24)
        .alertLocalizedError($vm.error, title: "Login Failed")
        .navigationTitle("Sign In")
        .navigationBarTitleDisplayMode(.inline)
    }
}
```

### LoginViewModel.swift
```swift
import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email      = ""
    @Published var password   = ""
    @Published var isLoading  = false
    @Published var error: AuthError?
    @Published private(set) var canSignIn = false

    private let authService: AuthService
    private let googleCoordinator: GoogleSignInCoordinator

    private var cancellables = Set<AnyCancellable>()

    init(
        authService: AuthService,
        googleCoordinator: GoogleSignInCoordinator
    ) {
        self.authService        = authService
        self.googleCoordinator  = googleCoordinator

        Publishers.CombineLatest($email, $password)
            .map { email, pass in email.contains("@") && pass.count >= 6 }
            .assign(to: &$canSignIn)
    }

    func login() async {
        guard canSignIn else { return }
        isLoading = true; defer { isLoading = false }

        do {
            _ = try await authService.signIn(email: email, password: password)
            
        } catch let err as AuthError {
            self.error = err
        } catch {
            self.error = .networkError(underlying: error)
        }
    }

    func loginWithGoogle(idToken: String, accessToken: String) async {
        isLoading = true; defer { isLoading = false }

        do {
            _ = try await authService.signInWithGoogle(
                idToken:     idToken,
                accessToken: accessToken
            )
            // при успехе въю вызовет onSuccess()
        }
        catch AuthError.popupClosedByUser {
            return
        }
        catch let err as AuthError {
            self.error = err
        }
        catch {
            self.error = .networkError(underlying: error)
        }
    }
}
```

---

## Исходный код Features/Editor

### EditorView.swift
```swift
import SwiftUI
import PhotosUI
import PencilKit

struct EditorView: View {
    @StateObject private var vm: EditorViewModel
    @StateObject private var keyboard = KeyboardObserver()
    @StateObject private var previewCache = FilterPreviewCache()

    @State private var drawing   = PKDrawing()
    @State private var tool      = PKInkingTool(.pen, color: .black, width: 5)
    @State private var isErasing = false

    @State private var showSourceDialog = false
    @State private var showCameraPicker = false
    @State private var showLibraryPicker = false
    @State private var libraryItem: PhotosPickerItem?
    @State private var shareURL: URL?
    
    @FocusState private var focusedItemID: UUID?

    let filters = FilterProviderImpl().allFilters()
    let onShare:  () -> Void
    let onLogout: () -> Void

    init(
        vm: EditorViewModel,
        onShare: @escaping () -> Void,
        onLogout: @escaping () -> Void
    ) {
        _vm = StateObject(wrappedValue: vm)
        self.onShare  = onShare
        self.onLogout = onLogout
    }

    var body: some View {
            VStack(spacing: 0) {
                topTools
                canvasArea
                bottomTools
                filtersBar
            }
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .toolbar {
                navBar
                textToolbar
            }
            .overlay {
                ImageSourcePicker(
                    showDialog:  $showSourceDialog,
                    showCamera:  $showCameraPicker,
                    showLibrary: $showLibraryPicker,
                    libraryItem: $libraryItem
                ) { data in
                    if let img = UIImage(data: data) {
                        print("📐 Got image orientation rawValue:", img.imageOrientation.rawValue)
                        print("📐 Got image orientation description:", img.imageOrientation)
                     }
                    vm.inputData = data
                }
            }
            .sheet(item: $vm.shareItem, onDismiss: vm.clearShareItem) { item in
                ShareSheet(items: [item.image])
            }
            .onReceive(keyboard.$height) { newH in
                vm.updateKeyboard(h: newH)
            }
            .onChange(of: vm.markup) { old, new in
                if new == .text {
                    vm.textVM.enterPlacement()
                } else {
                    vm.textVM.finishEditing()
                }
            }
            .onChange(of: vm.originalImage) { old, image in
                previewCache.preparePreviews(for: image, filters: filters)
                vm.textVM.reset()
            }
            .onAppear {
                if let image = vm.originalImage {
                    previewCache.preparePreviews(for: image, filters: filters)
                }
            }
    }
}
```

### EditorViewModel.swift
```swift
import SwiftUI
import Combine
import PencilKit

@MainActor
final class EditorViewModel: ObservableObject {
    @Published var markup: MarkupTool = .none
    
    @Published var keyboardHeight: CGFloat = 0
    @Published var inputData: Data?
    @Published var selectedFilter: Filter? = nil
    @Published private(set) var previewImage: UIImage? = nil
    @Published var canvasSize: CGSize = .zero
    @Published var rotationCount = 0
    @Published var isFlippedHorizontally = false
    @Published private(set) var originalImage: UIImage? = nil
    @Published var shareItem: ShareItem?
    
    let textVM = TextOverlayViewModel()
    
    private let transformService: TransformService
    private let filterService:    FilterService
    private let exportService:    ExportService
    private let overlayService:   OverlayRenderService
    private let previewService:   PreviewRenderService
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        transformService: TransformService,
        filterService:    FilterService,
        exportService:    ExportService,
        overlayService:   OverlayRenderService,
        previewService:   PreviewRenderService = PreviewRenderServiceImpl()
    ) {
        self.transformService = transformService
        self.filterService    = filterService
        self.exportService    = exportService
        self.overlayService   = overlayService
        self.previewService   = previewService
        
        Publishers
            .CombineLatest($inputData, $selectedFilter)
            .debounce(for: .milliseconds(120), scheduler: RunLoop.main)
            .sink { [weak self] raw, fx in
                self?.updatePreview(raw: raw, filter: fx)
            }
            .store(in: &cancellables)
        
        $inputData
            .sink { [weak self] data in
                guard let data else { self?.originalImage = nil; return }
                self?.originalImage = UIImage(data: data)
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest($originalImage, $selectedFilter)
            .sink { [weak self] image, filter in
                guard let self = self else { return }
                self.previewImage = self.apply(filter: filter, to: image)
            }
            .store(in: &cancellables)
    }
    
    func startDraw() {
        markup = .draw
        textVM.finishEditing()
    }
    
    func startText() {
        markup = .text
        textVM.enterPlacement()
    }
    
    func finishMarkup() {
        markup = .none
        textVM.finishEditing()
    }
    
    func updateKeyboard(h: CGFloat) {
        keyboardHeight = h
    }
    
    func share(drawingOverlay: PKDrawing?) {
        Task { @MainActor in
            print("🛠 share started")
            do {
                let item = try await makeShareItem(drawingOverlay: drawingOverlay)
                shareItem = item
            } catch {
                print("❌ share error:", error.localizedDescription)
            }
        }
    }
    
    func clearShareItem() {
        shareItem = nil
    }
}
```

---

## Исходный код Navigation

### RootView.swift
```swift
// Navigation/RootView.swift

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var session: SessionStore
    let container:             AppDependencyContainer
    let onLogout:              () -> Void

    init(container: AppDependencyContainer, onLogout: @escaping () -> Void) {
        self.container = container
        self.onLogout  = onLogout
    }

    var body: some View {
        NavigationStack {
            if !session.didFinishChecking {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else if session.isAuthenticated {
                EditorView(
                    vm:       container.makeEditorViewModel(),
                    onShare:  { Task { try? await container.makeEditorViewModel().exportFinalImage() } },
                    onLogout: onLogout
                )
            }
            else {
                AuthStackView(
                    container: container,
                    onLogin:   { /* после логина обновится session.isAuthenticated */ }
                )
            }
        }
        .environmentObject(session)
    }
}
```

---

## Исходный код Core/Utilities

### KeyboardObserver.swift
```swift
import SwiftUI
import Combine

class KeyboardObserver: ObservableObject {
    @Published var height: CGFloat = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { notification in
                notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            }
            .map { $0.height }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] height in
                self?.height = height
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.height = 0
            }
            .store(in: &cancellables)
    }
}
```

### ShareSheet.swift
```swift
import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
```

---

## Последние изменения

1. Улучшена работа с текстом:
   - Текст теперь появляется в фиксированной позиции над клавиатурой
   - Добавлен кастомный тулбар с инструментами форматирования
   - Улучшен UX при добавлении и редактировании текста
   - Оптимизирована работа с клавиатурой
   - Исправлено дублирование тулбара
   - Добавлена подсказка при размещении текста

2. Оптимизация производительности:
   - Улучшена работа с памятью
   - Оптимизирована обработка изображений
   - Улучшена работа с UI-компонентами
   - Оптимизирована обработка жестов

3. Улучшения в обработке состояний:
   - Добавлен флаг didFinishChecking в SessionStore
   - Улучшена обработка ошибок
   - Оптимизирована работа с асинхронными операциями
   - Улучшена обработка состояний клавиатуры

4. Новые функции редактора:
   - Добавлена поддержка PencilKit для рисования
   - Реализована работа с текстовыми слоями
   - Улучшена система фильтров
   - Добавлена поддержка экспорта в различные форматы
   - Добавлена поддержка перетаскивания текста
   - Улучшена работа с размерами холста
