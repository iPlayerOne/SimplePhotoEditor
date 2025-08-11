# SimplePhotoEditor — Full Project Code Overview

Этот файл содержит обзор структуры и кода проекта SimplePhotoEditor. Для удобства навигации приведены основные файлы и их содержимое (или назначение), сгруппированные по модулям и папкам.

---

## Features/Auth

- **AuthRoute.swift**
- **AuthRouter.swift**
- **AuthStackView.swift**
- **GoogleSignInCoordinator.swift**
- **LoginView.swift**
- **RegistrationView.swift**
- **ResetPasswordView.swift**
- **Components/** — UI-компоненты для авторизации
- **ViewModels/** — ViewModel'и для авторизации

## Features/Editor

- **CameraPicker.swift**
- **EditModeSelector.swift**
- **EditorNavigationBar.swift**
- **EditorStates.swift**
- **EditorView.swift**
- **ImageSourcePicker.swift**
- **Components/** — UI-компоненты редактора
- **Models/** — модели редактора
- **ViewModels/** — ViewModel'и редактора

## Core/Models

- **Filter.swift** — модель фильтра
- **Photo.swift** — модель фотографии
- **ShareItem.swift** — модель для шаринга
- **Stroke.swift** — модель штриха
- **TextItem.swift** — модель текстового элемента
- **User.swift** — модель пользователя

## Core/Services

- **Auth/** — сервисы аутентификации (например, FirebaseAuthService.swift)
- **Camera/** — сервисы камеры
- **Export/** — сервисы экспорта
- **Processing/** — сервисы обработки изображений и фильтров

## Core/State

#### AppState.swift
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

## Core/Utilities

#### FilterWidthKey.swift
```swift
import SwiftUI

struct FilterWidthKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
```

#### KeyboardObserver.swift
```swift
import SwiftUI
import Combine

final class KeyboardObserver: ObservableObject {
    @Published private(set) var height: CGFloat = 0
    private var cancellable: AnyCancellable?
    
    init() {
        let willShow = NotificationCenter.default.publisher(
            for: UIResponder.keyboardWillShowNotification
        )
        let willHide = NotificationCenter.default.publisher(
            for: UIResponder.keyboardWillHideNotification
        )
        
        cancellable = Publishers.Merge(willShow, willHide)
            .compactMap { ($0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height }
            .map { $0 * ($0 > 0 ? 1 : 0) }
            .receive(on: DispatchQueue.main)
            .assign(to: \.height, on: self)
    }
}
```

#### ShareSheet.swift
```swift
import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
    }
    
    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) {}
}
```

#### UIImage+SafeDecode.swift
```swift
import UIKit

extension UIImage {
    static func safelyDecode(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(source, 0, nil)
        else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
}
```

### Extensions

#### Color+UIColor.swift
```swift
import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red:   Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue:  Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
```

#### Image+Filter.swift
```swift
import SwiftUI

extension Image {
    static let filterIcon = Image(systemName: "camera.filters")
    static let textIcon  = Image(systemName: "textformat")
    static let drawIcon  = Image(systemName: "pencil.tip")
    static let undoIcon  = Image(systemName: "arrow.uturn.backward")
    static let redoIcon  = Image(systemName: "arrow.uturn.forward")
    static let trash     = Image(systemName: "trash")
    static let share     = Image(systemName: "square.and.arrow.up")
    static let camera    = Image(systemName: "camera")
    static let photo     = Image(systemName: "photo")
}
```

#### String+CamelCase.swift
```swift
import Foundation

extension String {
    var camelCaseToWords: String {
        unicodeScalars.reduce("") { result, scalar in
            let string = String(scalar)
            if let first = string.first, first.isUppercase {
                return result + " " + string
            }
            return result + string
        }.trimmingCharacters(in: .whitespaces)
    }
}
```

### Modifiers

#### AlertModifier.swift
```swift
import SwiftUI

struct AlertModifier: ViewModifier {
    let title: String
    @Binding var error: Error?
    
    func body(content: Content) -> some View {
        content
            .alert(title, isPresented: .init(
                get: { error != nil },
                set: { if !$0 { error = nil } }
            )) {
                Button("OK") { error = nil }
            } message: {
                if let error = error {
                    Text(error.localizedDescription)
                }
            }
    }
}

extension View {
    func alert(
        _ title: String = "Ошибка",
        error: Binding<Error?>
    ) -> some View {
        modifier(AlertModifier(title: title, error: error))
    }
}
```

#### Draggable.swift
```swift
import SwiftUI

struct Draggable: ViewModifier {
    @Binding var position: CGPoint
    @Binding var active: Bool
    @State private var isDragging = false
    
    func body(content: Content) -> some View {
        content
            .position(position)
            .gesture(dragGesture)
            .onChange(of: isDragging) { wasDragging, isDragging in
                active = isDragging
            }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                position = value.location
                if !isDragging {
                    isDragging = true
                }
            }
            .onEnded { _ in
                isDragging = false
            }
    }
}
```

#### IconStyle.swift
```swift
import SwiftUI

struct IconStyle: ViewModifier {
    let isEnabled: Bool
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: 20, weight: .medium))
            .foregroundStyle(isEnabled ? Color.accentColor : .secondary)
    }
}

extension View {
    func iconStyle(isEnabled: Bool = true) -> some View {
        modifier(IconStyle(isEnabled: isEnabled))
    }
}
```

#### Liftable.swift
```swift
import SwiftUI

struct Liftable: ViewModifier {
    let isLifted: Bool
    let scale: CGFloat
    
    init(isLifted: Bool, scale: CGFloat = 1.1) {
        self.isLifted = isLifted
        self.scale = scale
    }
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isLifted ? scale : 1)
            .shadow(
                color: .black.opacity(isLifted ? 0.2 : 0),
                radius: isLifted ? 10 : 0,
                y: isLifted ? 5 : 0
            )
            .zIndex(isLifted ? 1 : 0)
    }
}

extension View {
    func liftable(
        isLifted: Bool,
        scale: CGFloat = 1.1
    ) -> some View {
        modifier(Liftable(isLifted: isLifted, scale: scale))
    }
}
```

#### ShimmerModifier.swift
```swift
import SwiftUI

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    let duration = 1.0
    let bounce = false
    
    func body(content: Content) -> some View {
        content
            .mask(ShimmerLayer().fill(style: .init(eoFill: true)))
            .overlay(ShimmerLayer().stroke())
            .onAppear {
                withAnimation(
                    .linear(duration: duration)
                    .repeatForever(autoreverses: bounce)
                ) {
                    phase = bounce ? 1 : 2
                }
            }
    }
    
    struct ShimmerLayer: Shape {
        func path(in rect: CGRect) -> Path {
            Path { path in
                path.addRoundedRect(
                    in: rect,
                    cornerSize: .init(
                        width: rect.height / 2,
                        height: rect.height / 2
                    )
                )
            }
        }
    }
}

extension View {
    func shimmer(active: Bool = true) -> some View {
        if active {
            return AnyView(modifier(ShimmerModifier()))
        }
        return AnyView(self)
    }
}
```

#### UnderlineModifier.swift
```swift
import SwiftUI

struct UnderlineModifier: ViewModifier {
    let color: Color
    let height: CGFloat
    
    init(
        color: Color = .accentColor,
        height: CGFloat = 3
    ) {
        self.color = color
        self.height = height
    }
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(color)
                    .frame(height: height)
                    .offset(y: height)
            }
    }
}

extension View {
    func underline(
        color: Color = .accentColor,
        height: CGFloat = 3
    ) -> some View {
        modifier(UnderlineModifier(
            color: color,
            height: height
        ))
    }
}
```

### Navigation

#### RootView.swift
```swift
import SwiftUI

struct RootView: View {
    @EnvironmentObject private var session: SessionStore
    let container: AppDependencyContainer
    let onLogout: () -> Void

    init(container: AppDependencyContainer, onLogout: @escaping () -> Void) {
        self.container = container
        self.onLogout = onLogout
    }

    var body: some View {
        NavigationStack {
            if !session.didFinishChecking {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else if session.isAuthenticated {
                EditorView(
                    vm: container.makeEditorViewModel(),
                    onShare: { Task { try? await container.makeEditorViewModel().exportFinalImage() } },
                    onLogout: onLogout
                )
            }
            else {
                AuthStackView(
                    container: container,
                    onLogin: { /* после логина обновится session.isAuthenticated */ }
                )
            }
        }
        .environmentObject(session)
    }
}
```

## Features

#### Auth

##### AuthRoute.swift
```swift
enum AuthRoute: Hashable {
    case signUp
    case resetPassword
}
```

##### AuthRouter.swift
```swift
import SwiftUI

struct AuthRouter: View {
    @Binding var path: [AuthRoute]
    let container: AppDependencyContainer
    
    var body: some View {
        NavigationStack(path: $path) {
            LoginView(
                vm: container.makeLoginViewModel(),
                onRegister: { path.append(.signUp) },
                onResetPassword: { path.append(.resetPassword) }
            )
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .signUp:
                    RegistrationView(vm: container.makeRegistrationViewModel())
                case .resetPassword:
                    ResetPasswordView(vm: container.makeResetPasswordViewModel())
                }
            }
        }
    }
}
```

##### AuthStackView.swift
```swift
import SwiftUI

struct AuthStackView: View {
    @State private var path: [AuthRoute] = []
    let container: AppDependencyContainer
    
    var body: some View {
        AuthRouter(
            path: $path,
            container: container
        )
    }
}
```

##### GoogleSignInCoordinator.swift
```swift
import GoogleSignIn

protocol GoogleSignInCoordinator {
    func signIn() async throws -> (idToken: String, accessToken: String)
}

final class GoogleSignInCoordinatorImpl: GoogleSignInCoordinator {
    private let clientID: String
    
    init(clientID: String) {
        self.clientID = clientID
    }
    
    func signIn() async throws -> (idToken: String, accessToken: String) {
        try await withCheckedThrowingContinuation { continuation in
            let config = GIDConfiguration(clientID: clientID)
            
            GIDSignIn.sharedInstance.signIn(
                with: config,
                presenting: UIApplication.shared.activeWindow!
            ) { user, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let user = user,
                      let idToken = user.idToken?.tokenString,
                      let accessToken = user.accessToken.tokenString
                else {
                    continuation.resume(throwing: AuthError.invalidCredential)
                    return
                }
                
                continuation.resume(returning: (idToken, accessToken))
            }
        }
    }
}

private extension UIApplication {
    var activeWindow: UIWindow? {
        connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
    }
}
```

##### LoginView.swift
```swift
import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @StateObject private var vm: LoginViewModel
    let onRegister: () -> Void
    let onResetPassword: () -> Void
    
    init(
        vm: LoginViewModel,
        onRegister: @escaping () -> Void,
        onResetPassword: @escaping () -> Void
    ) {
        _vm = StateObject(wrappedValue: vm)
        self.onRegister = onRegister
        self.onResetPassword = onResetPassword
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
                    placeholder: "Password",
                    text: $vm.password,
                    isSecure: true
                )
            }
            
            VStack(spacing: 16) {
                PrimaryActionButton(
                    title: "Sign In",
                    isLoading: vm.isLoading
                ) {
                    await vm.signIn()
                }
                
                Button("Forgot Password?", action: onResetPassword)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 16) {
                HStack {
                    Rectangle()
                        .frame(height: 1)
                    Text("or")
                        .foregroundColor(.secondary)
                    Rectangle()
                        .frame(height: 1)
                }
                .foregroundColor(.secondary.opacity(0.3))
                
                GoogleSignInButton(
                    viewModel: .init(scheme: .dark, style: .wide),
                    action: vm.signInWithGoogle
                )
            }
            .padding(.vertical)
            
            Button {
                onRegister()
            } label: {
                Text("Don't have an account? ")
                    .foregroundColor(.secondary)
                +
                Text("Sign Up")
                    .foregroundColor(.accentColor)
            }
        }
        .padding()
        .alert(error: $vm.error)
    }
}
```

##### ViewModels/LoginViewModel.swift
```swift
import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var error: Error?
    
    private let authService: AuthService
    private let googleCoordinator: GoogleSignInCoordinator
    
    init(
        authService: AuthService,
        googleCoordinator: GoogleSignInCoordinator
    ) {
        self.authService = authService
        self.googleCoordinator = googleCoordinator
    }
    
    func signIn() async {
        do {
            isLoading = true
            defer { isLoading = false }
            
            _ = try await authService.signIn(
                email: email,
                password: password
            )
        } catch {
            self.error = error
        }
    }
    
    func signInWithGoogle() async {
        do {
            isLoading = true
            defer { isLoading = false }
            
            let (idToken, accessToken) = try await googleCoordinator.signIn()
            _ = try await authService.signInWithGoogle(
                idToken: idToken,
                accessToken: accessToken
            )
        } catch {
            self.error = error
        }
    }
}
```

##### ViewModels/RegistrationViewModel.swift
```swift
import Foundation

@MainActor
final class RegistrationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var error: Error?
    
    private let authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    var isValid: Bool {
        !email.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword
    }
    
    func register() async {
        do {
            isLoading = true
            defer { isLoading = false }
            
            _ = try await authService.register(
                email: email,
                password: password
            )
        } catch {
            self.error = error
        }
    }
}
```

##### ViewModels/ResetPasswordViewModel.swift
```swift
import Foundation

@MainActor
final class ResetPasswordViewModel: ObservableObject {
    @Published var email = ""
    @Published var isLoading = false
    @Published var error: Error?
    @Published var isSuccess = false
    
    private let authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
    }
    
    func resetPassword() async {
        do {
            isLoading = true
            defer { isLoading = false }
            
            try await authService.resetPassword(email: email)
            isSuccess = true
        } catch {
            self.error = error
        }
    }
}
```

#### Editor

##### EditorView.swift
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
                showDialog: $showSourceDialog,
                showCamera: $showCameraPicker,
                showLibrary: $showLibraryPicker,
                libraryItem: $libraryItem
            ) { imageData in
                vm.inputData = imageData
            }
        }
        .sheet(item: $vm.shareItem) { item in
            ShareSheet(items: [item.image])
        }
        .onReceive(keyboard.$height) { newHeight in
            vm.updateKeyboard(h: newHeight)
        }
        .onChange(of: vm.markup) { old, new in
            if new == .text {
                vm.textVM.enterPlacement()
            } else {
                vm.textVM.finishEditing()
            }
        }
        .onChange(of: vm.originalImage) { old, image in
            if let image = image {
                previewCache.preparePreviews(for: image, filters: filters)
            }
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

##### EditorStates.swift
```swift
import Foundation

enum MarkupMode {
    case none
    case draw
    case text
}

enum TextEditingState {
    case none
    case placement
    case editing(UUID)
}
```

##### EditorNavigationBar.swift
```swift
import SwiftUI

struct EditorNavigationBar: ToolbarContent {
    @Binding var showSourceDialog: Bool
    let isShareEnabled: Bool
    let onShare: () -> Void
    let onLogout: () -> Void
    
    var body: some ToolbarContent {
        ToolbarItem(placement: .topBarLeading) {
            Button(action: onLogout) {
                Image(systemName: "arrow.backward")
                    .iconStyle()
            }
        }
        
        ToolbarItem(placement: .principal) {
            Button {
                showSourceDialog = true
            } label: {
                Image(systemName: "photo.fill")
                    .iconStyle()
            }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: onShare) {
                Image(systemName: "square.and.arrow.up")
                    .iconStyle(isEnabled: isShareEnabled)
            }
            .disabled(!isShareEnabled)
        }
    }
}
```

##### ImageSourcePicker.swift
```swift
import SwiftUI
import PhotosUI

struct ImageSourcePicker: View {
    @Binding var showDialog: Bool
    @Binding var showCamera: Bool
    @Binding var showLibrary: Bool
    @Binding var libraryItem: PhotosPickerItem?
    
    let onImageSelected: (Data) -> Void
    
    var body: some View {
        EmptyView()
            .photosPicker(
                isPresented: $showLibrary,
                selection: $libraryItem,
                matching: .images
            )
            .onChange(of: libraryItem) { old, item in
                guard let item = item else { return }
                Task {
                    guard let data = try? await item.loadTransferable(type: Data.self)
                    else { return }
                    onImageSelected(data)
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPicker { data in
                    onImageSelected(data)
                }
            }
            .confirmationDialog(
                "Выберите источник фото",
                isPresented: $showDialog,
                titleVisibility: .visible
            ) {
                Button("Камера") { showCamera = true }
                Button("Галерея") { showLibrary = true }
                Button("Отмена", role: .cancel) {}
            }
    }
}
```

##### CameraPicker.swift
```swift
import SwiftUI

struct CameraPicker: UIViewControllerRepresentable {
    let onCapture: (Data) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(
        _ uiViewController: UIImagePickerController,
        context: Context
    ) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onCapture: onCapture)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let onCapture: (Data) -> Void
        
        init(onCapture: @escaping (Data) -> Void) {
            self.onCapture = onCapture
        }
        
        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            picker.dismiss(animated: true)
            
            guard let image = info[.originalImage] as? UIImage,
                  let data = image.jpegData(compressionQuality: 0.8)
            else { return }
            
            onCapture(data)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
```

##### EditModeSelector.swift
```swift
import SwiftUI

struct EditModeSelector: View {
    @Binding var mode: MarkupMode
    let disabled: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Button {
                mode = .draw
            } label: {
                Image.drawIcon
                    .iconStyle(isEnabled: !disabled && mode == .draw)
            }
            .disabled(disabled)
            
            Button {
                mode = .text
            } label: {
                Image.textIcon
                    .iconStyle(isEnabled: !disabled && mode == .text)
            }
            .disabled(disabled)
        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal)
    }
}
```

##### ViewModels/EditorViewModel.swift
```swift
import SwiftUI
import PencilKit

@MainActor
final class EditorViewModel: ObservableObject {
    @Published var inputData: Data? {
        didSet { processInputData() }
    }
    @Published var originalImage: UIImage?
    @Published var previewImage: UIImage?
    @Published var markup: MarkupMode = .none
    @Published var textVM: TextOverlayViewModel
    @Published var shareItem: ShareItem?
    @Published var error: Error?
    
    private var imageSize: CGSize = .zero
    private var keyboardHeight: CGFloat = 0
    
    private let transformService: TransformService
    private let filterService: FilterService
    private let exportService: ExportService
    private let overlayService: OverlayRenderService
    
    init(
        transformService: TransformService,
        filterService: FilterService,
        exportService: ExportService,
        overlayService: OverlayRenderService
    ) {
        self.transformService = transformService
        self.filterService = filterService
        self.exportService = exportService
        self.overlayService = overlayService
        
        let textVM = TextOverlayViewModel()
        self.textVM = textVM
        
        // Подписываемся на изменения текста
        textVM.$overlay
            .dropFirst()
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .sink { [weak self] overlay in
                self?.renderPreview()
            }
            .store(in: &textVM.cancellables)
    }
    
    private func processInputData() {
        guard let data = inputData,
              let image = UIImage.safelyDecode(data)
        else { return }
        
        let fixed = transformService.fixOrientation(image)
        self.imageSize = fixed.size
        self.originalImage = fixed
        self.previewImage = fixed
    }
    
    func updateKeyboard(h: CGFloat) {
        keyboardHeight = h
        textVM.updateKeyboard(h: h)
    }
    
    // MARK: - Применение изменений
    
    @Published var selectedFilter: Filter = .none {
        didSet { applyFilter() }
    }
    
    private func applyFilter() {
        guard let image = originalImage else { return }
        previewImage = filterService.apply(selectedFilter, to: image)
        renderPreview()
    }
    
    func renderPreview() {
        guard let image = previewImage else { return }
        
        if let overlay = overlayService.renderTextOverlay(
            textVM.overlay.items,
            in: .init(origin: .zero, size: imageSize),
            scale: 1
        ) {
            previewImage = ImageComposeServiceImpl().compose(
                background: image,
                overlay: overlay
            )
        }
    }
    
    func share(drawingOverlay: PKDrawing) {
        do {
            guard let image = previewImage else { return }
            
            let drawingImage = DrawServiceImpl().renderDrawing(
                drawingOverlay,
                in: .init(origin: .zero, size: imageSize)
            )
            
            if let drawingImage {
                self.previewImage = ImageComposeServiceImpl().compose(
                    background: image,
                    overlay: drawingImage
                )
            }
            
            shareItem = .init(image: previewImage!)
            
            try await exportService.saveToPhotos(previewImage!)
        } catch {
            self.error = error
        }
    }
}
```

#### SessionStore.swift
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

#### Editor/Components

##### FilterTools/FilterPreviewImage.swift
```swift
import SwiftUI

struct FilterPreviewImage: View {
    let image: UIImage?
    let isSelected: Bool
    
    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Color.secondary
                    .opacity(0.2)
                    .shimmer()
            }
        }
        .frame(width: 60, height: 60)
        .clipShape(.rect(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.accentColor, lineWidth: 2)
                .opacity(isSelected ? 1 : 0)
        }
    }
}
```

##### FilterTools/FilterPreviewCache.swift
```swift
import SwiftUI

@MainActor
final class FilterPreviewCache: ObservableObject {
    @Published private(set) var previews: [Filter: UIImage] = [:]
    
    private let filterService = FilterServiceImpl()
    private let previewService = PreviewRenderServiceImpl()
    
    func preparePreviews(
        for image: UIImage,
        filters: [Filter]
    ) {
        Task {
            let size = CGSize(width: 60, height: 60)
            
            guard let preview = previewService.renderPreview(
                for: image,
                size: size
            ) else { return }
            
            for filter in filters {
                guard let filtered = filterService.apply(filter, to: preview)
                else { continue }
                
                previews[filter] = filtered
            }
        }
    }
    
    func preview(for filter: Filter) -> UIImage? {
        previews[filter]
    }
}
```

##### FilterTools/FilterToolsPanel.swift
```swift
import SwiftUI

struct FilterToolsPanel: View {
    let filters: [Filter]
    @Binding var selectedFilter: Filter
    @ObservedObject var cache: FilterPreviewCache
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(filters) { filter in
                    FilterPreviewImage(
                        image: cache.preview(for: filter),
                        isSelected: filter == selectedFilter
                    )
                    .onTapGesture {
                        selectedFilter = filter
                    }
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 80)
    }
}
```

##### Preview/CanvasLayer.swift
```swift
import SwiftUI
import PencilKit

struct CanvasLayer: UIViewRepresentable {
    @Binding var drawing: PKDrawing
    let tool: PKInkingTool
    let isErasing: Bool
    
    func makeUIView(context: Context) -> PKCanvasView {
        let canvas = PKCanvasView()
        canvas.tool = tool
        canvas.isOpaque = false
        canvas.backgroundColor = .clear
        canvas.drawingPolicy = .anyInput
        return canvas
    }
    
    func updateUIView(_ canvas: PKCanvasView, context: Context) {
        canvas.drawing = drawing
        canvas.tool = isErasing ? PKEraserTool(.bitmap) : tool
    }
}
```

##### Preview/PhotoLayer.swift
```swift
import SwiftUI

struct PhotoLayer: View {
    let image: UIImage?
    
    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
        }
    }
}
```

##### Preview/PreviewArea.swift
```swift
import SwiftUI
import PencilKit

struct PreviewArea: View {
    @ObservedObject var vm: EditorViewModel
    @ObservedObject var textVM: TextOverlayViewModel
    @Binding var drawing: PKDrawing
    @Binding var tool: PKInkingTool
    @Binding var isErasing: Bool
    @Binding var showSourceDialog: Bool
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Color.black
                    .opacity(0.1)
                
                if let image = vm.previewImage {
                    PhotoLayer(image: image)
                        .overlay {
                            TextOverlayLayer(
                                vm: textVM,
                                canvasSize: proxy.size
                            )
                        }
                        .overlay {
                            if vm.markup == .draw {
                                CanvasLayer(
                                    drawing: $drawing,
                                    tool: tool,
                                    isErasing: isErasing
                                )
                            }
                        }
                } else {
                    Button {
                        showSourceDialog = true
                    } label: {
                        VStack(spacing: 16) {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 40))
                            Text("Добавить фото")
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}
```

##### Preview/TextOverlayLayer.swift
```swift
import SwiftUI

struct TextOverlayLayer: View {
    @ObservedObject var vm: TextOverlayViewModel
    let canvasSize: CGSize
    
    var body: some View {
        ForEach(vm.overlay.items) { item in
            TextItemView(
                text: item.text,
                fontName: item.fontName,
                fontSize: item.fontSize,
                color: item.color,
                position: item.position,
                isSelected: vm.activeID == item.id,
                onTap: {
                    vm.editItem(item.id)
                }
            )
        }
    }
}
```

##### Preview/ZoomableView.swift
```swift
import SwiftUI

struct ZoomableView<Content: View>: View {
    let content: Content
    @GestureState private var scale: CGFloat = 1
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .scaleEffect(scale)
            .gesture(
                MagnificationGesture()
                    .updating($scale) { value, scale, _ in
                        scale = value
                    }
            )
    }
}
```
