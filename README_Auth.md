# SimplePhotoEditor — Аутентификация и Регистрация

## Описание
Данный документ описывает структуру, основные компоненты и flow, связанные с авторизацией и регистрацией пользователей в приложении SimplePhotoEditor. Также приведён обзор ключевых файлов ядра (Core) и приложения (App), необходимых для работы всех фич.

---

## Структура проекта (релевантная часть)

```
SimplePhotoEditor/
├── App/
│   ├── AppDelegate.swift
│   ├── AppConfig.swift
│   ├── DependencyContainer.swift
│   └── SimplePhotoEditorApp.swift
├── Core/
│   ├── Models/
│   │   ├── User.swift
│   │   └── ...
│   ├── Services/
│   │   ├── Auth/
│   │   │   ├── AuthError.swift
│   │   │   └── FirebaseAuthService.swift
│   │   └── ...
├── Features/
│   └── Auth/
│       ├── Components/
│       ├── ViewModels/
│       ├── AuthStackView.swift
│       ├── LoginView.swift
│       ├── RegistrationView.swift
│       └── ResetPasswordView.swift
├── Navigation/
│   └── RootView.swift
├── Info.plist
└── GoogleService-Info.plist
```

---

## Flow авторизации и регистрации

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

### 9. Обработка ошибок
- **Сетевые ошибки** → `AuthError.networkError(underlying)`
- **Firebase ошибки** → маппинг в `AuthError` (неверный пароль, пользователь не найден и т.д.)
- **Google ошибки** → `AuthError.popupClosedByUser`, `AuthError.invalidCredential`
- **Отображение** → через `.alertLocalizedError($vm.error)` с локализованными сообщениями

---

## Ключевые файлы

### App/
- **AppDelegate.swift** — делегат приложения, инициализация сервисов (Firebase, GoogleSignIn)
- **AppConfig.swift** — конфигурация приложения (например, clientID для Google)
- **DependencyContainer.swift** — DI-контейнер, собирает зависимости для фич
- **SimplePhotoEditorApp.swift** — точка входа, инициализация сессии и зависимостей
- **Info.plist** — настройки приложения

### Core/Models/
- **User.swift** — модель пользователя
- ... (другие модели, если используются в auth)

### Core/Services/Auth/
- **AuthError.swift** — ошибки аутентификации
- **FirebaseAuthService.swift** — реализация сервисов аутентификации через Firebase

### Core/State/
- **SessionStore.swift** — хранит состояние сессии пользователя, подписка на изменения

### Features/Auth/
- **Components/** — UI-компоненты для форм и кнопок
- **ViewModels/** — view model'и для логики авторизации, регистрации, сброса пароля
- **AuthStackView.swift** — корневой стек для auth flow
- **LoginView.swift** — экран входа
- **RegistrationView.swift** — экран регистрации
- **ResetPasswordView.swift** — восстановление пароля
- **GoogleSignInCoordinator.swift** — интеграция с Google Sign-In

### Navigation/
- **RootView.swift** — корневой view приложения, переключает между auth/editor flows

---

## Пример сценария

- Пользователь запускает приложение
- Если не авторизован — видит форму входа/регистрации
- Может войти через email или Google
- После входа — попадает в редактор

---

## Требования
- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+
- Firebase, GoogleSignIn

---

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
            return "Пароль слишком простой (минимум 6 символов)."
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

### RegistrationView.swift
```swift
import SwiftUI

struct RegistrationView: View {
    @StateObject var vm: RegistrationViewModel
    @EnvironmentObject var router: AuthRouter

    var body: some View {
        VStack(spacing: 32) {
            Text("Создать аккаунт")
                .font(.largeTitle.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            AuthTextField(
                placeholder: "Электронная почта",
                text: $vm.email,
                keyboard: .emailAddress,
                textContentType: .emailAddress
            )

            AuthTextField(
                placeholder: "Пароль (мин. 6 символов)",
                text: $vm.password,
                isSecure: true,
                textContentType: .newPassword
            )

            AuthTextField(
                placeholder: "Повторите пароль",
                text: $vm.repeatPassword,
                isSecure: true,
                textContentType: .newPassword
            )

            PrimaryActionButton(
                title: "Зарегистрироваться",
                enabled: vm.canRegister
            ) {
                Task { await vm.register() }
            }

            if vm.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }

            Spacer()
        }
        .padding(24)
        .navigationTitle("Регистрация")
        .navigationBarTitleDisplayMode(.inline)
        // Показываем ошибку из vm.error
        .alertLocalizedError($vm.error, title: "Ошибка регистрации")
        // После успешной регистрации — уведомление и возврат назад
        .alert("Письмо отправлено",
               isPresented: $vm.didRegister) {
            Button("OK") {
                router.path.removeLast()
            }
        } message: {
            Text("Пожалуйста, подтвердите свою почту в письме.")
        }
    }
}
```

### ResetPasswordView.swift
```swift
import SwiftUI

struct ResetPasswordView: View {
    @StateObject var vm: ResetPasswordViewModel
    @EnvironmentObject var router: AuthRouter

    var body: some View {
        VStack(spacing: 32) {
            // Заголовок экрана
            Text("Восстановление пароля")
                .font(.largeTitle.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            // Поле для email
            AuthTextField(
                placeholder: "Электронная почта",
                text: $vm.email,
                keyboard: .emailAddress,
                textContentType: .emailAddress
            )

            // Кнопка отправки
            PrimaryActionButton(
                title: "Отправить ссылку",
                enabled: vm.canReset
            ) {
                Task { await vm.resetPassword() }
            }

            // Индикатор загрузки
            if vm.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }

            Spacer()
        }
        .padding(24)
        .navigationTitle("Забыли пароль?")
        .navigationBarTitleDisplayMode(.inline)
        // Ошибки авторизации
        .alertLocalizedError($vm.error, title: "Ошибка")
        // Успешная отправка
        .alert(
            "Письмо отправлено",
            isPresented: $vm.didSend
        ) {
            Button("OK") {
                // Возвращаемся назад
                router.path.removeLast()
            }
        } message: {
            Text("Проверьте вашу почту для дальнейших инструкций.")
        }
    }
}
```

### AuthStackView.swift
```swift
// Features/Auth/AuthStackView.swift

import SwiftUI

/// Стек экранов для авторизации (Sign In / Sign Up / Reset Password)
struct AuthStackView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var authRouter = AuthRouter()
    private let container: AppDependencyContainer
    private let onLogin: () -> Void

    init(
        container: AppDependencyContainer,
        onLogin: @escaping () -> Void
    ) {
        self.container = container
        self.onLogin = onLogin
    }

    var body: some View {
        NavigationStack(path: $authRouter.path) {
            // стартовый экран — LoginView с колбэком onSuccess
            LoginView(
                vm: container.makeLoginViewModel(),
                googleCoordinator: container.makeGoogleSignInCoordinator(),
                onSuccess: onLogin
            )
            .environmentObject(authRouter)
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .signUp:
                    RegistrationView(
                        vm: container.makeRegistrationViewModel()
                    )
                    .environmentObject(authRouter)

                case .resetPassword:
                    ResetPasswordView(
                        vm: container.makeResetPasswordViewModel()
                    )
                    .environmentObject(authRouter)
                }
            }
        }
    }
}
```

### GoogleSignInCoordinator.swift
```swift
import Foundation
import GoogleSignIn

protocol GoogleSignInCoordinator {
    func signIn() async throws -> (idToken: String, accessToken: String)
}

@MainActor
final class GoogleSignInCoordinatorImpl: GoogleSignInCoordinator {
    init(clientID: String) {
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
    }

    func signIn() async throws -> (idToken: String, accessToken: String) {
        guard
            let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
            let presenter = scene.windows.first(where: \.isKeyWindow)?
                .rootViewController
        else {
            throw AuthError.unknown
        }

        let result = try await GIDSignIn.sharedInstance.signIn(
            withPresenting: presenter
        )

        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.popupClosedByUser
        }
        let accessToken = result.user.accessToken.tokenString
        return (idToken, accessToken)
    }
}
```

### AuthRoute.swift
```swift
enum AuthRoute: Hashable {
  case signUp
  case resetPassword
}
```

### AuthRouter.swift
```swift
import SwiftUI

final class AuthRouter: ObservableObject {
    @Published var path: [AuthRoute] = []
    
}
```

---

## Исходный код Features/Auth/Components

### AuthButtonStyle.swift
```swift
import SwiftUI

struct AuthButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.accentColor)
                    .opacity(configuration.isPressed ? 0.7 : 1)
            )
            .foregroundColor(.white)
    }
}

extension ButtonStyle where Self == AuthButtonStyle {
    static var authPrimary: AuthButtonStyle { .init() }
}
```

### AuthFieldModifier.swift
```swift
import SwiftUI

struct AuthFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Color.secondary.opacity(0.3), lineWidth: 1)
            )
            .font(.body)
    }
}

extension View {
    func authFieldStyle() -> some View {
        modifier(AuthFieldModifier())
    }
}
```

### AuthTextField.swift
```swift
import SwiftUI

struct AuthTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var isSecure: Bool = false
    var textContentType: UITextContentType? = nil

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textContentType(textContentType)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboard)
                    .autocapitalization(.none)
                    .textContentType(textContentType)
            }
        }
        .authFieldStyle()
    }
}

#Preview {
    AuthTextField(placeholder: "Username", text: .constant("qwerty"), isSecure: true)
}
```

### PrimaryActionButton.swift
```swift
import SwiftUI

struct PrimaryActionButton: View {
    let title: String
    let enabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.authPrimary)
        .disabled(!enabled)
    }
}

#Preview {
    PrimaryActionButton(title: "Test", enabled: true, action: {})
}
```

---

## Исходный код Features/Auth/ViewModels

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

### RegistrationViewModel.swift
```swift
import Foundation
import Combine
import FirebaseAuth

@MainActor
class RegistrationViewModel: ObservableObject {
    @Published var email          = ""
    @Published var password       = ""
    @Published var repeatPassword = ""
    
    @Published var isLoading      = false
    @Published var error: AuthError?
    @Published var didRegister    = false
    
    @Published private(set) var canRegister = false
    
    private var cancellables = Set<AnyCancellable>()
    private let authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
        
        Publishers.CombineLatest3($email, $password, $repeatPassword)
            .map { email, pwd, rep in
                let emailOK = email.contains("@") && email.contains(".")
                let pwdOK   = pwd.count >= 6
                let match   = pwd == rep
                return emailOK && pwdOK && match
            }
            .assign(to: &$canRegister)
    }
    
    func register() async {
        guard canRegister else { return }
        isLoading = true
        
        do {
            _ = try await authService.register(email: email, password: password)
            // если успешно — покажем алерт
            didRegister = true
        }
        catch let err as AuthError {
            // перехватываем конкретную ошибку «email уже занят»
            self.error = err
        }
        catch {
            // всё остальное как сетевые сбои
            self.error = .networkError(underlying: error)
        }
        
        isLoading = false
    }
}
```

### ResetPasswordViewModel.swift
```swift
import Foundation
import Combine

@MainActor
class ResetPasswordViewModel: ObservableObject {
    @Published var email = ""

    @Published var isLoading = false
    @Published var error: AuthError?
    @Published var didSend = false
    @Published private(set) var canReset = false

    private var cancellables = Set<AnyCancellable>()
    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService

        $email
            .map { $0.contains("@") && $0.contains(".") }
            .assign(to: &$canReset)
    }

    func resetPassword() async {
        guard canReset else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            try await authService.resetPassword(email: email)
            didSend = true
        } catch let err as AuthError {
            self.error = err
        } catch {
            self.error = .networkError(underlying: error)
        }
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

### FilterWidthKey.swift
```swift
import SwiftUI

struct FilterWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
```

### CanvasMetrics.swift
```swift
import SwiftUI

struct CanvasMetrics {
    let canvasSize: CGSize
    let imageSize: CGSize?
    let keyboardHeight: CGFloat
    
    var displaySize: CGSize {
        guard let imageSize = imageSize else { return canvasSize }
        
        let imageAspect = imageSize.width / imageSize.height
        let canvasAspect = canvasSize.width / canvasSize.height
        
        if imageAspect > canvasAspect {
            let height = canvasSize.width / imageAspect
            return CGSize(width: canvasSize.width, height: height)
        } else {
            let width = canvasSize.height * imageAspect
            return CGSize(width: width, height: canvasSize.height)
        }
    }
    
    var verticalInset: CGFloat {
        (canvasSize.height - displaySize.height) / 2
    }
}
```

### GeometryHelper.swift
```swift
import SwiftUI

struct GeometryHelper {
    static func centerPoint(in rect: CGRect) -> CGPoint {
        CGPoint(x: rect.midX, y: rect.midY)
    }
    
    static func distance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
        sqrt(pow(point2.x - point1.x, 2) + pow(point2.y - point1.y, 2))
    }
}
```

### UIImage+SafeDecode.swift
```swift
import UIKit

extension UIImage {
    static func safeDecode(from data: Data) -> UIImage? {
        guard let image = UIImage(data: data) else { return nil }
        
        if image.cgImage != nil {
            return image
        }
        
        // Попытка исправить проблему с ориентацией
        guard let cgImage = image.cgImage else { return nil }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}
