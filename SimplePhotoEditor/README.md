# SimplePhotoEditor

## Структура проекта

```
SimplePhotoEditor/
├── App/
│   ├── AppDelegate.swift
│   ├── AppConfig.swift
│   ├── DependencyContainer.swift
│   └── SimplePhotoEditorApp.swift
├── AppDependency/
│   └── AppDependencyContainer.swift
├── Core/
│   ├── Extensions/
│   ├── Models/
│   ├── Protocols/
│   ├── Services/
│   │   ├── Auth/
│   │   ├── Processing/
│   │   └── State/
│   └── Utilities/
├── Features/
│   ├── Auth/
│   │   ├── Components/
│   │   ├── ViewModels/
│   │   ├── AuthStackView.swift
│   │   ├── LoginView.swift
│   │   ├── RegistrationView.swift
│   │   └── ResetPasswordView.swift
│   └── Editor/
│       ├── Components/
│       │   ├── Preview/
│       │   │   ├── PhotoLayer.swift
│       │   │   ├── PencilCanvasView.swift
│       │   │   ├── PreviewArea.swift
│       │   │   ├── TextItemView.swift
│       │   │   └── TextOverlayLayer.swift
│       │   └── Tools/
│       │       ├── EditorNavigationBar.swift
│       │       ├── ImageSourcePicker.swift
│       │       ├── ModeTabBar.swift
│       │       ├── TextToolsToolbar.swift
│       │       ├── ToolsPanel.swift
│       │       └── TopToolsPanel.swift
│       ├── Models/
│       │   ├── EditorMode.swift
│       │   └── TextItem.swift
│       ├── Utilities/
│       │   └── KeyboardObserver.swift
│       ├── ViewModels/
│       │   ├── EditorViewModel.swift
│       │   └── TextOverlayViewModel.swift
│       └── EditorView.swift
├── Navigation/
│   └── RootView.swift
├── Assets.xcassets/
├── Info.plist
└── GoogleService-Info.plist
```

## Файлы редактора

### Компоненты редактора

#### Preview/
- `PhotoLayer.swift` - Слой для отображения фотографии
- `PencilCanvasView.swift` - Холст для рисования с поддержкой PencilKit
- `PreviewArea.swift` - Основная область предпросмотра, объединяющая все слои
- `TextItemView.swift` - Представление для отдельного текстового элемента
- `TextOverlayLayer.swift` - Слой для управления текстовыми элементами

#### Tools/
- `EditorNavigationBar.swift` - Навигационная панель редактора
- `ImageSourcePicker.swift` - Выбор источника изображения (камера/галерея)
- `ModeTabBar.swift` - Панель переключения режимов редактирования
- `TextToolsToolbar.swift` - Панель инструментов для работы с текстом
- `ToolsPanel.swift` - Основная панель инструментов
- `TopToolsPanel.swift` - Верхняя панель инструментов

### Модели
- `EditorMode.swift` - Перечисление режимов редактирования
- `TextItem.swift` - Модель текстового элемента

### Утилиты
- `KeyboardObserver.swift` - Наблюдатель за состоянием клавиатуры

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