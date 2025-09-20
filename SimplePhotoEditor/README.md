# SimplePhotoEditor

Приложение для iOS (SwiftUI, MVVM) с авторизацией (Email/Google) и простым фоторедактором: кадрирование/трансформации, фильтры Core Image, рисование PencilKit, текстовые слои и экспорт.

## Быстрый старт
1) Откройте `SimplePhotoEditor.xcodeproj` в Xcode.
2) Через SPM установите зависимости (если Xcode предложит).
3) Создайте проект в Firebase и скачайте `GoogleService-Info.plist` в корень таргета.
4) Включите Sign-In with Google в Firebase, добавьте URL Schemes из `GoogleService-Info.plist` в `Info.plist` таргета.
5) Запустите на iOS 15+ симуляторе или устройстве.

## Возможности
- Авторизация: email/пароль, Google, сброс пароля.
- Редактор: фильтры Core Image, поворот/зеркалирование, PencilKit-рисование, текстовые слои, экспорт/ShareSheet.
- Производительность: кеш превью фильтров, оптимизированный пайплайн CI, безопасное декодирование UIImage.

## Архитектура
- **UI**: SwiftUI, feature-модули `Auth` и `Editor`.
- **Состояние**: `SessionStore` (наблюдение за auth), `EditorViewModel` и `TextOverlayViewModel`.
- **Сервисы**: `Auth`, `Processing` (фильтры, пайплайн, композиция, трансформации), `Export`, `Camera`.
- **Внедрение зависимостей**: `DependencyContainer` в `App/`.

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

## Файлы редактора

### Компоненты редактора

#### Preview/
- `CanvasLayer.swift` - Слой холста, объединяющий подслои
- `PhotoLayer.swift` - Слой для отображения фотографии
- `PencilCanvasView.swift` - Холст для рисования с поддержкой PencilKit
- `PreviewArea.swift` - Основная область предпросмотра
- `TextItemView.swift` - Представление для отдельного текстового элемента
- `TextOverlayLayer.swift` - Слой для управления текстовыми элементами
- `ZoomableView.swift` - Зум и панорамирование предпросмотра

#### Tools/
- `DrawToolsPanel.swift` - Инструменты рисования (кисть/ластик/толщина/цвет)
- `EditorTopBar.swift` - Верхняя панель инструментов редактора
- `FilterToolsPanel.swift` - Панель превью и выбора фильтров
- `FilterPreviewCache.swift` - Кеширование превью фильтров
- `TextToolsToolbar.swift` - Инструменты редактирования текста
- `ToolsPanel.swift` - Основная панель инструментов
- `TopToolControls.swift` - Общие кнопки управления сверху

#### KeyboardAccessory/
- `AccessoryHostingController.swift` - Хостинг SwiftUI над клавиатурой
- `KeyboardAccessory.swift` - Кастомный аксессуар над клавиатурой

#### Tab/
- `ModeButton.swift` - Кнопка режима
- `ModeTabBar.swift` - Переключение режимов редактирования

### Модели
- `EditorMode.swift` (Features/Editor/Models) - Режимы редактирования
- `TextItem.swift` (Core/Models) - Текстовый элемент

### Утилиты
- `KeyboardObserver.swift` - Наблюдатель за состоянием клавиатуры
- `CanvasMetrics.swift` - Подсчёт размеров холста/масштабов
- `GeometryHelper.swift` - Геометрические преобразования/ограничения
- `PanelSurface.swift` - Стиль поверхности панелей
- Расширения: `Color+UIColor.swift`, `Image+Filter.swift`, `String+CamelCase.swift`

### ViewModels
- `EditorViewModel.swift` - Основная модель представления редактора
- `TextOverlayViewModel.swift` - Модель представления для работы с текстом

## Основные компоненты

### AppDelegate.swift
```swift
import UIKit
import FirebaseCore
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
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

### SimplePhotoEditorApp.swift
```swift
import SwiftUI
import FirebaseCore

@main
struct SimplePhotoEditorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var session: SessionStore
    private let container: AppDependencyContainer

    init() {
        FirebaseApp.configure()
        let authService = FirebaseAuthService()
        let sessionStore = SessionStore(authService: authService)
        _session = StateObject(wrappedValue: sessionStore)
        container = AppDependencyContainer(authService: authService)
    }

    var body: some Scene {
        WindowGroup {
            RootView(
                container: container,
                onLogout: { session.logout() }
            )
            .environmentObject(session)
        }
    }
}
```

### AppDependencyContainer.swift
```swift
@MainActor
final class AppDependencyContainer {
    private let authService: AuthService
    private let exportService: ExportService
    private let transformService: TransformService
    private let filterService: FilterService
    private let composeService: ImageComposeService
    private let textService: TextOverlayService

    init(
        authService: AuthService = FirebaseAuthService(),
        exportService: ExportService = ExportServiceImpl(),
        transformService: TransformService = TransformServiceImpl(),
        filterService: FilterService = FilterServiceImpl(),
        composeService: ImageComposeService = ImageComposeServiceImpl(),
        textService: TextOverlayService = TextOverlayServiceImpl()
    ) {
        self.authService = authService
        self.exportService = exportService
        self.transformService = transformService
        self.filterService = filterService
        self.composeService = composeService
        self.textService = textService
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
        EditorViewModel(
            transformService: transformService,
            filterService: filterService,
            composeService: composeService,
            textService: textService,
            exportService: exportService
        )
    }
}
```

### SessionStore.swift
```swift
@MainActor
final class SessionStore: ObservableObject {
    @Published var isAuthenticated: Bool
    @Published var didFinishChecking = false

    private let authService: AuthService
    private var cancellable: AnyCancellable?

    init(authService: AuthService = FirebaseAuthService()) {
        self.authService = authService
        let initial = Auth.auth().currentUser != nil
        self.isAuthenticated = initial

        cancellable = authService.authStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.isAuthenticated = (user != nil)
                self?.didFinishChecking = true
            }
    }

    func logout() {
        try? authService.signOut()
    }
}
```

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