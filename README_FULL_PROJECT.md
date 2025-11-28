# SimplePhotoEditor — Полный README (актуально)

Этот файл содержит актуальную структуру, содержимое файлов и ключевые исходники для SimplePhotoEditor. Все примеры кода синхронизированы с реальными файлами проекта.

## Требования и запуск

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+
- Firebase + GoogleSignIn

Быстрый старт:
1) Откройте `SimplePhotoEditor.xcodeproj` в Xcode.
2) Подтяните зависимости через SPM, если потребуется.
3) Добавьте `GoogleService-Info.plist` в таргет `SimplePhotoEditor/`.
4) Проверьте URL Schemes в `SimplePhotoEditor/App/Info.plist`.
5) Запустите на устройстве/симуляторе iOS 15+.

---

## Структура проекта (актуально)

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
│       │   ├── CanvasSyncModifier.swift
│       │   ├── CanvasTransform.swift
│       │   ├── Draggable.swift
│       │   ├── IconStyle.swift
│       │   ├── Liftable.swift
│       │   ├── PanelSurface.swift
│       │   ├── ShimmerModifier.swift
│       │   ├── ToolbarGlyphModifier.swift
│       │   └── UnderlineModifier.swift
│       ├── PixelSnap.swift
│       ├── ShareSheet.swift
│       └── UIImage+SafeDecode.swift
├── Features/
│   ├── Auth/
│   │   ├── AuthRoute.swift
│   │   ├── AuthRouter.swift
│   │   ├── AuthStackView.swift
│   │   ├── Components/
│   │   │   ├── AuthButtonStyle.swift
│   │   │   ├── AuthFieldModifier.swift
│   │   │   ├── AuthTextField.swift
│   │   │   └── PrimaryActionButton.swift
│   │   ├── GoogleSignInCoordinator.swift
│   │   ├── LoginView.swift
│   │   ├── RegistrationView.swift
│   │   ├── ResetPasswordView.swift
│   │   ├── ValidationMessageModifier.swift
│   │   └── ViewModels/
│   │       ├── EmailValidator.swift
│   │       ├── LoginViewModel.swift
│   │       ├── RegistrationViewModel.swift
│   │       └── ResetPasswordViewModel.swift
│   └── Editor/
│       ├── CameraPicker.swift
│       ├── Components/
│       │   ├── FilterTools/
│       │   │   ├── FilteredImageView.swift
│       │   │   ├── FilterPreviewCache.swift
│       │   │   ├── FilterPreviewImage.swift
│       │   │   └── FilterToolsPanel.swift
│       │   ├── KeyboardAccessory/
│       │   │   ├── AccessoryHostingController.swift
│       │   │   └── KeyboardAccessory.swift
│       │   ├── Preview/
│       │   │   ├── CanvasStack.swift
│       │   │   ├── PencilCanvasView.swift
│       │   │   ├── PhotoLayer.swift
│       │   │   ├── PreviewArea.swift
│       │   │   ├── TextItemView.swift
│       │   │   ├── TextOverlayLayer.swift
│       │   │   └── ZoomableView.swift
│       │   ├── PrimaryGlassButtonStyle.swift
│       │   ├── SourcePicker/
│       │   ├── Tab/
│       │   │   ├── ModeButton.swift
│       │   │   └── ModeTabBar.swift
│       │   └── Tools/
│       │       ├── DrawToolsPanel.swift
│       │       ├── EditorTopBar.swift
│       │       ├── TextToolsToolbar.swift
│       │       └── ToolsPanel.swift
│       ├── EditModeSelector.swift
│       ├── EditorNavigationBar.swift
│       ├── EditorStates.swift
│       ├── EditorView.swift
│       ├── FontOption.swift
│       ├── ImageSourcePicker.swift
│       ├── Models/
│       │   └── EditorMode.swift
│       └── ViewModels/
│           ├── EditorViewModel.swift
│           ├── ImageSourcePickerViewModel.swift
│           └── TextOverlayViewModel.swift
├── GoogleService-Info.plist
├── Navigation/
│   └── RootView.swift
└── README.md
```

---

## Содержимое ключевых файлов

### App Layer

#### SimplePhotoEditorApp.swift
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
                onLogout:  { session.logout() }
            )
            .onAppear {
                let s = UIScreen.main
                print("📱 scale=\(s.scale), nativeScale=\(s.nativeScale), bounds=\(s.bounds.size), nativeBounds=\(s.nativeBounds.size)")
            }
            .environmentObject(session)
        }
    }
}
```

#### AppDelegate.swift
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

#### AppConfig.swift
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

#### DependencyContainer.swift
```swift
import Foundation

@MainActor
final class AppDependencyContainer {

    private let transformService = TransformServiceImpl()
    private let filterService    = FilterServiceImpl()
    private let overlayService   = OverlayRenderServiceImpl()
    private let decodeService    = ImageDecodeServiceImpl()
    private let previewService   = PreviewRenderServiceImpl()
    private let exportService    = ExportServiceImpl()
    
    let cameraAccessService: CameraAccess = CameraAccessService()

    private lazy var imagePipeline: ImagePipeline = {
        ImagePipelineImpl(
            decode:   decodeService,
            transform: transformService,
            filter:    filterService,
            overlay:   overlayService
        )
    }()

    let authService: AuthService
    let googleCoordinator: GoogleSignInCoordinator

    init(authService: AuthService = FirebaseAuthService()) {
        _ = CIContextPool.shared
        self.authService       = authService
        self.googleCoordinator = GoogleSignInCoordinatorImpl(
            clientID: AppConfig.googleClientID
        )
    }

    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(
            authService:       authService,
            googleCoordinator: googleCoordinator
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
            pipeline:       imagePipeline,
            exportService:  exportService
        )
    }
}
```

### Core Models

#### User.swift
```swift
struct User {
    let uid: String
    let email: String
}
```

#### Photo.swift
```swift
import Foundation

struct Photo: Identifiable {
    let id: UUID = UUID()
    let imageData: Data
    let creationDate: Date
}
```

#### Filter.swift
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

#### TextItem.swift
```swift
import SwiftUI
import Observation

@Observable
final class TextItem: Identifiable {
    let id = UUID()

    var text: String
    var font: FontOption
    var fontSize: Double
    var color: Color
    var position: CGPoint
    var isEditing: Bool

    init(
        text: String,
        font: FontOption,
        fontSize: Double,
        color: Color,
        position: CGPoint,
        isEditing: Bool = false
    ) {
        self.text = text
        self.font = font
        self.fontSize = fontSize
        self.color = color
        self.position = position
        self.isEditing = isEditing
    }
}
```

#### ShareItem.swift
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

#### Stroke.swift
```swift
import SwiftUI

struct Stroke: Identifiable {
    let id: UUID = UUID()
    var points: [CGPoint]
    let lineWidth: CGFloat
    let color: Color
}
```

### Core Services

#### FirebaseAuthService.swift
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
            if result.user.isEmailVerified == false {
                try? Auth.auth().signOut()
                throw AuthError.emailNotVerified
            }
            
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
                    case .userDisabled:
                        throw AuthError.userDisabled
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
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch {
            let ns = error as NSError
            if let code = AuthErrorCode(rawValue: ns.code) {
                switch code {
                    case .invalidEmail:
                        throw AuthError.invalidEmailFormat
                    case .userNotFound:
                        return
                    case .tooManyRequests:
                        throw AuthError.tooManyRequests
                    case .networkError:
                        throw AuthError.networkError(underlying: ns)
                    default:
                        throw AuthError.networkError(underlying: ns)
                }
            }
            throw AuthError.networkError(underlying: ns)
        }
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

#### AuthError.swift
```swift
import Foundation

enum AuthError: Error, Identifiable {
    case emailAlreadyInUse
    case invalidEmailFormat
    case userNotFound
    case wrongPassword
    case weakPassword
    case userDisabled
    case tooManyRequests
    case emailNotVerified

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
            return String(localized: "auth.error.email_in_use")
        case .invalidEmailFormat:
            return String(localized: "auth.error.invalid_email")
        case .userNotFound:
            return String(localized: "auth.error.user_not_found")
        case .wrongPassword:
            return String(localized: "auth.error.wrong_password")
        case .weakPassword:
            return String(localized: "auth.error.weak_password")
        case .userDisabled:
            return String(localized: "auth.error.user_disabled")
        case .tooManyRequests:
            return String(localized: "auth.error.too_many_requests")
        case .emailNotVerified:
            return String(localized: "auth.error.email_not_verified")
        case .accountExistsWithDifferentCredential:
            return String(localized: "auth.error.account_exists_with_different_credential")
        case .credentialAlreadyInUse:
            return String(localized: "auth.error.credential_already_in_use")
        case .invalidCredential:
            return String(localized: "auth.error.invalid_credential")
        case .popupClosedByUser:
            return String(localized: "auth.error.popup_closed_by_user")
        case .operationNotAllowed:
            return String(localized: "auth.error.operation_not_allowed")

        case .networkError:
            return String(localized: "auth.error.network")
        case .unknown:
            return String(localized: "auth.error.unknown")
        }
    }
}

extension AuthError: LocalizedError {
    var errorDescription: String? { localizedDescription }
}
```

#### ExportService.swift
```swift
import PhotosUI
import UIKit

enum ExportFormat {
    case jpeg
    case png
}

enum ExportError: Error {
    case permissionDenied
    case writeFailed
    case encodeFailed
}

protocol ExportService {
    func makeShareURL(from data: Data, format: ExportFormat) throws -> URL
    func saveToPhotos(_ data: Data) async throws
}

final class ExportServiceImpl: ExportService {
    func makeShareURL(from data: Data, format: ExportFormat = .jpeg) throws -> URL {
        switch format {
        case .jpeg:
            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("jpg")

            guard (try? data.write(to: url, options: .atomic)) != nil else {
                throw ExportError.writeFailed
            }

            print("📤 ExportService: wrote JPEG to \(url.lastPathComponent) (\(data.count) bytes)")
            return url

        case .png:
            guard let ui = UIImage(data: data),
                  let pngData = ui.pngData()
            else {
                throw ExportError.encodeFailed
            }

            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("png")

            guard (try? pngData.write(to: url, options: .atomic)) != nil else {
                throw ExportError.writeFailed
            }

            print("📤 ExportService: wrote PNG to \(url.lastPathComponent) (\(pngData.count) bytes)")
            return url
        }
    }

    func saveToPhotos(_ data: Data) async throws {
        guard try await requestAddOnlyPermission() else {
            throw ExportError.permissionDenied
        }
        
        try await PHPhotoLibrary.shared().performChanges {
            PHAssetCreationRequest.forAsset()
                .addResource(with: .photo, data: data, options: nil)
        }
        print("📸 ExportService: saved image to Photos (\(data.count) bytes)")
    }

    private func requestAddOnlyPermission() async throws -> Bool {
        let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
        if status == .authorized { return true }
        let next = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        return next == .authorized
    }
}
```

#### CameraService.swift
```swift
import AVFoundation
import UIKit

enum CameraGateResult { case granted, denied, unavailable }

protocol CameraAccess {
    func authorizeIfNeeded() async -> CameraGateResult
}

final class CameraAccessService: CameraAccess {
    func authorizeIfNeeded() async -> CameraGateResult {
        guard await UIImagePickerController.isSourceTypeAvailable(.camera) else {
            return .unavailable
        }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                return .granted
            case .notDetermined:
                let ok = await withCheckedContinuation { cont in
                    AVCaptureDevice.requestAccess(for: .video) { cont.resume(returning: $0) }
                }
                return ok ? .granted : .denied
            case .denied, .restricted:
                return .denied
            @unknown default:
                return .denied
        }
    }
}
```

#### ImagePipeline.swift
```swift
import UIKit
import PencilKit

protocol ImagePipeline {
    func makePreview(from data: Data, filterName: String?, downscaleFactor: CGFloat) async -> UIImage?
    func makeFinalImage(
        from data: Data,
        filterName: String?,
        rotation: Int,
        isFlipped: Bool,
        drawing: PKDrawing?,
        texts: [TextItem]?,
        canvasSize: CGSize,
        imageSize: CGSize
    ) async throws -> Data
}

final class ImagePipelineImpl: ImagePipeline {
    private let decode: ImageDecodeService
    private let transform: TransformService
    private let filter: FilterService
    private let overlay: OverlayRenderService

    init(decode: ImageDecodeService, transform: TransformService, filter: FilterService, overlay: OverlayRenderService) {
        self.decode = decode
        self.transform = transform
        self.filter = filter
        self.overlay = overlay
    }

    func makePreview(from data: Data, filterName: String?, downscaleFactor: CGFloat) async -> UIImage? {
        let decode = self.decode
        let filter = self.filter

        return await Task.detached(priority: .userInitiated) {
            guard let preview = await decode.downsample(data, maxDimension: 600, UIScreen.main.scale) else {
                return nil
            }
            guard let name = filterName, !name.isEmpty else {
                return preview
            }
            guard
                let jpeg = preview.jpegData(compressionQuality: 0.9),
                let filteredData = try? filter.apply(filterName: name, to: jpeg, downscaleFactor: downscaleFactor),
                let filteredPreview = UIImage(data: filteredData)
            else {
                return preview
            }
            return filteredPreview
        }.value
    }

    func makeFinalImage(
        from data: Data,
        filterName: String?,
        rotation: Int,
        isFlipped: Bool,
        drawing: PKDrawing?,
        texts: [TextItem]?,
        canvasSize: CGSize,
        imageSize: CGSize
    ) async throws -> Data {
        let transform = self.transform
        let filter = self.filter
        let overlay = self.overlay

        return try await Task.detached(priority: .userInitiated) {
            var out = data

            if rotation != 0 {
                out = try transform.rotate90(data: out, times: rotation)
            }
            if isFlipped {
                out = try transform.flipHorizontal(data: out)
            }

            if let name = filterName, !name.isEmpty {
                out = try filter.apply(filterName: name, to: out, downscaleFactor: 1.0)
            }

            let hasTexts = !(texts?.isEmpty ?? true)
            if drawing != nil || hasTexts {
                out = try overlay.apply(
                    drawing: drawing,
                    texts: texts,
                    to: out,
                    canvasSize: canvasSize,
                    imageSize: imageSize
                )
            }

            return out
        }.value
    }
}
```

#### OverlayRenderService.swift
```swift
import UIKit
import PencilKit
import UniformTypeIdentifiers
import ImageIO

protocol OverlayRenderService {
    func apply(drawing: PKDrawing?, texts: [TextItem]?, to data: Data, canvasSize: CGSize, imageSize: CGSize) throws -> Data
}

enum OverlayRenderError: Error {
    case invalidBase
    case encodeFailed
}

final class OverlayRenderServiceImpl: OverlayRenderService {
    
    func apply(drawing: PKDrawing?, texts: [TextItem]?, to data: Data, canvasSize: CGSize, imageSize: CGSize) throws -> Data {
        let base = try decodeBaseImage(from: data)
        
        let mapping = CanvasMapping(canvasSize: canvasSize, imageSize: imageSize, baseSize: base.size)
        
        let rendered = render(base: base, drawing: drawing, texts: texts, mapping: mapping)
        
        return try encodeJPEG(rendered, quality: 0.9)
    }
    
    private func decodeBaseImage(from data: Data) throws -> UIImage {
        guard let img = UIImage(data: data) else {
            throw OverlayRenderError.invalidBase
        }
        return img
    }
    
    private func encodeJPEG(_ image: UIImage, quality: CGFloat) throws -> Data {
        guard let out = image.jpegData(compressionQuality: quality) else {
            throw OverlayRenderError.encodeFailed
        }
        return out
    }
    
    private func render(base: UIImage, drawing: PKDrawing?, texts: [TextItem]?, mapping: CanvasMapping) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = base.scale
        format.opaque = true
        
        let renderer = UIGraphicsImageRenderer(size: base.size, format: format)
        
        return renderer.image { ctx in
            drawBase(base, in: ctx)
            
            if let drawing {
                drawDrawing(drawing, in: ctx, mapping: mapping)
            }
            if let texts, !texts.isEmpty {
                drawTexts(texts, in: ctx, mapping: mapping)
            }
        }
    }
    
    private func drawBase(_ base: UIImage, in ctx: UIGraphicsImageRendererContext) {
        base.draw(in: CGRect(origin: .zero, size: base.size))
    }
    
    private func drawDrawing(_ drawing: PKDrawing, in ctx: UIGraphicsImageRendererContext, mapping: CanvasMapping) {
        let overlay = drawing.image(from: CGRect(origin: .zero, size: mapping.canvasSize), scale: 1.0)
        
        ctx.cgContext.saveGState()
        ctx.cgContext.translateBy(
            x: -mapping.rectOnCanvas.minX * mapping.scaleToImage,
            y: -mapping.rectOnCanvas.minY * mapping.scaleToImage
        )
        ctx.cgContext.scaleBy(x: mapping.scaleToImage, y: mapping.scaleToImage)
        
        overlay.draw(in: CGRect(origin: .zero, size: mapping.canvasSize))
        ctx.cgContext.restoreGState()
    }
    
    private func drawTexts(_ items: [TextItem], in ctx: UIGraphicsImageRendererContext, mapping: CanvasMapping) {
        for item in items {
            let pt = mapping.canvasToImage(item.position)
            let fontSize = CGFloat(item.fontSize) * mapping.scaleToImage
            let attrs: [NSAttributedString.Key: Any] = [
                .font : item.font.uiFont(size: fontSize),
                .foregroundColor: item.color.uiColor
            ]
            let ns = item.text as NSString
            let ts = ns.size(withAttributes: attrs)
            let origin = CGPoint(x: pt.x - ts.width / 2, y: pt.y - ts.height / 2)
            ns.draw(at: origin, withAttributes: attrs)
        }
    }
}

private struct CanvasMapping {
    let canvasSize: CGSize
    let imageSize: CGSize
    let baseSize: CGSize
    
    let rectOnCanvas: CGRect
    let scaleToImage: CGFloat
    
    init(canvasSize: CGSize, imageSize: CGSize, baseSize: CGSize) {
        self.canvasSize = canvasSize
        self.imageSize = imageSize
        self.baseSize = baseSize
        
        let imgAspect = imageSize.width / max(imageSize.height, 0.0001)
        let canvasAspect = canvasSize.width / max(canvasSize.height, 0.0001)
        
        if imgAspect > canvasAspect {
            let w = canvasSize.width
            let h = w / imgAspect
            let y = (canvasSize.height - h) / 2
            self.rectOnCanvas = CGRect(x: 0, y: y, width: w, height: h)
        } else {
            let h = canvasSize.height
            let w = h * imgAspect
            let x = (canvasSize.width - w) / 2
            self.rectOnCanvas = CGRect(x: x, y: 0, width: w, height: h)
        }
        
        self.scaleToImage = baseSize.width / rectOnCanvas.width
    }
    
    func canvasToImage(_ p: CGPoint) -> CGPoint {
        return CGPoint(
            x: (p.x - rectOnCanvas.minX) * scaleToImage,
            y: (p.y - rectOnCanvas.minY) * scaleToImage
        )
    }
}
```

#### FilterService.swift
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

        ci = CIHelpers.lanczosScaled(ci, scale: downscaleFactor)

        let originalExtent = ci.extent.integral
        let clamped = ci.clampedToExtent()

        if !filterName.isEmpty, let fx = CIFilter(name: filterName) {
            fx.setValue(clamped, forKey: kCIInputImageKey)
            if let out = fx.outputImage {
                ci = out.cropped(to: originalExtent)
            }
        }

        let rect = ci.extent.integral
        guard let cg = CIContextPool.shared.createCGImage(ci, from: rect) else {
            throw FilterError.renderFailed
        }
        guard let jpeg = UIImage(cgImage: cg).jpegData(compressionQuality: 0.9) else {
            throw FilterError.renderFailed
        }
        return jpeg
    }
}
```

### Core State

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

### Core Utilities

#### ShareSheet.swift
```swift
import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    var items: [Any]
    var excluded: [UIActivity.ActivityType]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let vc = UIActivityViewController(activityItems: items, applicationActivities: nil)
        vc.excludedActivityTypes = excluded
        return vc
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
```

### Features

#### EditorMode.swift
```swift
import SwiftUI

enum EditorMode: Equatable  {
    case filters
    case draw
    case text
}
```

#### FontOption.swift
```swift
import SwiftUI
import CoreText

enum FontOption: Hashable, Identifiable {
    case system, rounded, serif, monospaced
    case named(String) // PostScript name

    var id: String {
        switch self {
        case .system: "system"
        case .rounded: "rounded"
        case .serif: "serif"
        case .monospaced: "monospaced"
        case .named(let n): "named:\(n)"
        }
    }

    // Для UI (меню/превью в SwiftUI)
    var displayName: String {
        switch self {
        case .system:      return "System"
        case .rounded:     return "System Rounded"
        case .serif:       return "System Serif"
        case .monospaced:  return "System Monospaced"
        case .named(let ps):
            // Красивое (локализованное) имя, если доступно
            let ct = CTFontCreateWithName(ps as CFString, 17, nil)
            return (CTFontCopyDisplayName(ct) as String?) ?? ps
        }
    }

    func font(size: CGFloat) -> Font {
        switch self {
        case .system:     return .system(size: size)
        case .rounded:    return .system(size: size, design: .rounded)
        case .serif:      return .system(size: size, design: .serif)
        case .monospaced: return .system(size: size, design: .monospaced)
        case .named(let ps):
            return UIFont(name: ps, size: size).map(Font.init) ?? .system(size: size)
        }
    }

    // Мост для рендера (UIKit / NSAttributedString)
    func uiFont(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        switch self {
        case .system:
            return .systemFont(ofSize: size, weight: weight)
        case .rounded, .serif, .monospaced:
            // Официальный способ получить SF Rounded / New York / SF Mono
            let base = UIFont.systemFont(ofSize: size, weight: weight)
            let design: UIFontDescriptor.SystemDesign =
                (self == .rounded) ? .rounded :
                (self == .serif) ? .serif : .monospaced
            if let d = base.fontDescriptor.withDesign(design) {
                return UIFont(descriptor: d, size: size)
            }
            return base
        case .named(let ps):
            return UIFont(name: ps, size: size) ?? .systemFont(ofSize: size, weight: weight)
        }
    }
}
```

#### ImageSourcePicker.swift
```swift
import SwiftUI

struct ImageSourcePicker: View {
    let onCamera: () -> Void
    let onLibrary: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            // Центрируем заголовок
            Text(String(localized: "editor.source.title"))
                .font(.headline)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                Button(action: onCamera) {
                    Text(String(localized: "editor.source.camera"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.sheetPrimaryGlass(isCancel: false))

                Button(action: onLibrary) {
                    Text(String(localized: "editor.source.gallery"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.sheetPrimaryGlass(isCancel: false))

                Button(action: onDismiss) {
                    Text(String(localized: "common.cancel"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.sheetPrimaryGlass(isCancel: true))
                .tint(.red)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.systemBackground).ignoresSafeArea())

        .presentationDetents([.fraction(0.28), .medium])
        .presentationDragIndicator(.hidden)
        .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.28)))
    }
}

#Preview("ImageSourcePicker") {
    struct Host: View {
        @State private var isPresented = true
        var body: some View {
            Color.clear
                .sheet(isPresented: $isPresented) {
                    ImageSourcePicker(
                        onCamera:  { isPresented = false },
                        onLibrary: { isPresented = false },
                        onDismiss: { isPresented = false }
                    )
                }
        }
    }
    return Host()
}
```

#### PrimaryGlassButtonStyle.swift
```swift
import SwiftUI

struct SheetPrimaryGlassButtonStyle: ButtonStyle {
    var isCancel: Bool = false
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Configuration) -> some View {
        let pressed   = configuration.isPressed && isEnabled
        let textTint  : Color = isCancel ? .white : .primary
        let bgTint    : Color = isCancel ? .red.opacity(0.22) : .clear
        let strokeTint: Color = isCancel
        ? .red.opacity(pressed ? 0.60 : 0.40)
        : .white.opacity(pressed ? 0.25 : 0.12)
        
        configuration.label
            .font(.title3.weight(.semibold))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: 60, alignment: .center)
            .contentShape(Capsule())
            .clipShape(Capsule())
        
        // фон капсулы (для Cancel — полупрозрачный красный)
            .background(Capsule().fill(bgTint))
        
        // стекло поверх формы
            .glassEffect(.regular.interactive(), in: Capsule())
        
        // обводка под роль
            .overlay(Capsule().stroke(strokeTint, lineWidth: 1))
        
        // цвет текста/символов
            .foregroundStyle(textTint)
            .tint(textTint)
        
            .opacity(isEnabled ? 1 : 0.6)
            .scaleEffect(pressed ? 0.98 : 1)
            .animation(.snappy(duration: 0.12), value: configuration.isPressed)
        
    }
}

extension ButtonStyle where Self == SheetPrimaryGlassButtonStyle {
    static func sheetPrimaryGlass(isCancel: Bool = false) -> SheetPrimaryGlassButtonStyle { .init(isCancel: isCancel) }
    static var sheetPrimaryGlassCancel: SheetPrimaryGlassButtonStyle { .init(isCancel: true) }
}
```

#### EditorViewModel.swift
```swift
import SwiftUI
import Combine
import PencilKit

@MainActor
final class EditorViewModel: ObservableObject {
    @Published var mode: EditorMode = .filters
    @Published var inputData: Data?
    @Published private(set) var previewImage: UIImage? = nil
    @Published private(set) var originalImage: UIImage? = nil
    
    @Published var selectedFilter: Filter? = nil
    @Published var rotationCount: Int = 0
    @Published var isFlippedHorizontally: Bool = false
    
    @Published var keyboardHeight: CGFloat = 0
    @Published var canvasSize: CGSize = .zero
    
    @Published var shareItem: ShareItem?
    
    // Было: exportAsPNG (Bool). Стало: формат экспорта.
    @Published var exportFormat: ExportFormat = .png
    
    private var pipeline: ImagePipeline
    private let exportService: ExportService
    
    let textVM = TextOverlayViewModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    init(
        pipeline: ImagePipeline,
        exportService:    ExportService
    ) {
        self.pipeline = pipeline
        self.exportService = exportService
        
        Publishers
            .CombineLatest($inputData, $selectedFilter)
            .debounce(for: .milliseconds(120), scheduler: RunLoop.main)
            .sink { [weak self] raw, fx in
                guard let self = self else { return }
                Task {
                    await self.updatePreview(raw: raw, filter: fx)
                }
                    
            }
            .store(in: &cancellables)
        
        $inputData
            .sink { [weak self] data in
                guard let data = data else {
                    self?.originalImage = nil
                    return
                }
                self?.originalImage = UIImage(data: data)
            }
            .store(in: &cancellables)
    }
    
    func setMode(_ newMode: EditorMode) {
        guard newMode != mode else { return }
        applyMode(from: mode, to: newMode)
        mode = newMode
    }
    
    func toogleMode(_ target: EditorMode) {
        setMode(mode == target ? .filters : target)
    }
    
    func startDraw() {
        toogleMode(.draw)
    }
    
    func startText() {
        toogleMode(.text)
    }
    
    func finishMarkup() {
        setMode(.filters)
    }
    
    func updateKeyboard(h: CGFloat) {
        keyboardHeight = h
    }
    
    func exportFinalImage(drawingOverlay: PKDrawing? = nil) async throws {
        let data = try await makeFinalImage(drawingOverlay: drawingOverlay)
        try await exportService.saveToPhotos(data)
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
    
    private func applyMode(from old: EditorMode, to new: EditorMode) {
        if new == .text, old != .text {
            textVM.enterPlacement()
        }
        
        if old == .text, new != .text {
            textVM.finishEditing()
        }
    }
    
    private func updatePreview(raw: Data?, filter: Filter?) async {
        guard let data = raw else {
            previewImage = nil
            return
        }
        
        let t0 = CFAbsoluteTimeGetCurrent()
        previewImage = await pipeline.makePreview(
            from: data,
            filterName: filter?.filterName,
            downscaleFactor: 0.25
        )
        
        let dt = CFAbsoluteTimeGetCurrent() - t0
               print("⏱ Preview render time: \(dt) sec")
    }
    
    private func makeFinalImage(drawingOverlay: PKDrawing?) async throws -> Data {
        guard let data = inputData, let img = originalImage, canvasSize != .zero else {
            throw OverlayRenderError.invalidBase
        }
        return try await pipeline.makeFinalImage(
            from: data,
            filterName: selectedFilter?.filterName,
            rotation: rotationCount,
            isFlipped: isFlippedHorizontally,
            drawing: drawingOverlay,
            texts: textVM.items,
            canvasSize: canvasSize,
            imageSize: img.size
        )
    }
    
    private func makeShareItem(drawingOverlay: PKDrawing?) async throws -> ShareItem {
        // Получаем итоговые данные изображения
        let data = try await makeFinalImage(drawingOverlay: drawingOverlay)
        // Формируем временный файл через ExportService с учетом формата
        let _ = try exportService.makeShareURL(from: data, format: exportFormat)
        // На данный момент ShareSheet шарит UIImage. Оставим как есть для минимальных правок.
        guard let ui = UIImage(data: data) else { throw OverlayRenderError.encodeFailed }
        return ShareItem(image: ui)
    }
}
```

#### TextOverlayViewModel.swift
```swift
import SwiftUI
import Observation

@Observable
final class TextOverlayViewModel {
    var items: [TextItem] = []
    var activeID: UUID?
    var isPlacing: Bool = false

    var currentColor: Color = .white {
        didSet { apply(.color(currentColor)) }
    }

    var currentSize: Double = 24 {
        didSet { apply(.size(currentSize)) }
    }

    var currentFont: FontOption = .system {
        didSet { apply(.font(currentFont)) }
    }

    var curatedFonts: [FontOption] = [
        .system, .rounded, .serif, .monospaced,
        .named("Georgia"), .named("AvenirNext-Regular"), .named("Menlo")
    ]

    private var waitForKeyboard: Bool = false

    func enterPlacement() {
        isPlacing = true
        activeID  = nil
        waitForKeyboard = true
    }

    func placeText(in canvas: CGSize, keyboardH: CGFloat, imageSize: CGSize?) {
        let frame = CanvasFrame(canvas: canvas, keyboard: keyboardH, imageSize: imageSize)
        let gapAboveKeyboard: CGFloat = 12

        let y: CGFloat
        if keyboardH > 0 {
            y = max(frame.minY, frame.maxY - gapAboveKeyboard)
        } else {
            y = frame.canvas.height / 2
        }

        let p = CGPoint(x: canvas.width / 2, y: y)

        let item = TextItem(
            text: "Текст",
            font: currentFont,
            fontSize: currentSize,
            color: currentColor,
            position: p,
            isEditing: true
        )
        items.append(item)
        activeID = item.id
        isPlacing = false
        waitForKeyboard = false
    }

    func setActive(id: UUID, editing: Bool = false) {
        activeID = id
        isPlacing = false
        if editing { mutateActive { $0.isEditing = true } }
    }

    func finishEditing() {
        mutateActive { $0.isEditing = false }
        activeID = nil
        isPlacing = true
    }

    func apply(_ edit: Edit) {
        mutateActive {
            switch edit {
            case .size(let s):  $0.fontSize = s
            case .color(let c): $0.color = c
            case .font(let f):  $0.font = f
            }
        }
    }

    func remove(id: UUID) {
        items.removeAll { $0.id == id }
        finishEditing()
    }

    func reset() {
        items.removeAll()
        activeID = nil
        isPlacing = false
        waitForKeyboard = false
    }

    func keyboardDidChange(_ h: CGFloat, canvas: CGSize, imageSize: CGSize?) {
        if waitForKeyboard, h > 0 {
            placeText(in: canvas, keyboardH: h, imageSize: imageSize)
            return
        }
        adjustPosition(canvas: canvas, keyboardH: h, imageSize: imageSize)
    }

    private func adjustPosition(canvas: CGSize, keyboardH: CGFloat, imageSize: CGSize?) {
        guard keyboardH > 0 else { return }

        let frame = CanvasFrame(canvas: canvas, keyboard: keyboardH, imageSize: imageSize)

        mutateActive { item in
            guard item.isEditing else { return }
            let y = min(max(item.position.y, frame.minY), frame.maxY)
            item.position = CGPoint(x: frame.canvas.width / 2, y: y)
        }
    }

    private func mutateActive(_ block: (inout TextItem) -> Void) {
        guard let id = activeID,
              let idx = items.firstIndex(where: { $0.id == id })
        else { return }
        block(&items[idx])
    }
}

extension TextOverlayViewModel {
    enum Edit {
        case size(Double)
        case color(Color)
        case font(FontOption)
    }
}

fileprivate struct CanvasFrame {
    let canvas: CGSize
    let minY: CGFloat
    let maxY: CGFloat

    init(canvas: CGSize, keyboard: CGFloat, imageSize: CGSize?, textH: CGFloat = 44, margin: CGFloat = 8) {
        let canvasRect = CGRect(origin: .zero, size: canvas)
        let fit = aspectFitRect(aspect: imageSize ?? canvas, in: canvasRect)

        let vInset = fit.minY

        minY = vInset + textH/2 + margin
        maxY = canvas.height - vInset - textH/2 - margin - keyboard
        self.canvas = canvas
    }
}
```

#### LoginView.swift
```swift
import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    // MARK: – Навигация внутри Auth
    @EnvironmentObject private var authRouter: AuthRouter

    // MARK: – ViewModel
    @StateObject private var vm: LoginViewModel

    // MARK: – Google Sign-In Coordinator
    let googleCoordinator: GoogleSignInCoordinator

    // MARK: – Сброс пароля (sheet)
    @State private var showReset = false
    private let makeResetVM: () -> ResetPasswordViewModel

    /// Колбэк, вызываемый после успешного логина (чтобы поднять флаг в RootView)
    let onSuccess: () -> Void

    // Focus + visited для подсказок «после ухода фокуса»
    @FocusState private var emailFocused: Bool
    @FocusState private var passwordFocused: Bool
    @State private var emailVisited = false
    @State private var passwordVisited = false

    init(
        vm: LoginViewModel,
        googleCoordinator: GoogleSignInCoordinator,
        onSuccess: @escaping () -> Void,
        resetVMFactory: @escaping () -> ResetPasswordViewModel
    ) {
        _vm = StateObject(wrappedValue: vm)
        self.googleCoordinator = googleCoordinator
        self.onSuccess = onSuccess
        self.makeResetVM = resetVMFactory
    }

    var body: some View {
        VStack(spacing: 32) {
            Text(String(localized: "auth.login.header"))
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 16) {
                // Email
                AuthTextField(
                    placeholder: String(localized: "auth.email.placeholder"),
                    text: $vm.email,
                    keyboard: .emailAddress,
                    textContentType: .emailAddress,
                    isFocused: $emailFocused
                )
                .onChange(of: emailFocused) {
                    if !emailFocused { emailVisited = true }
                }
                .validationMessage(
                    String(localized: "auth.validation.email.invalid"),
                    visible: emailVisited && !emailFocused && !vm.email.isEmpty && !EmailValidator.isValid(vm.email)
                )
                .submitLabel(.next)
                .onSubmit {
                    passwordFocused = true
                }

                // Password
                AuthTextField(
                    placeholder: String(localized: "auth.password.placeholder"),
                    text: $vm.password,
                    isSecure: true,
                    textContentType: .password,
                    isFocused: $passwordFocused
                )
                .onChange(of: passwordFocused) {
                    if !passwordFocused { passwordVisited = true }
                }
                .validationMessage(
                    String(localized: "auth.validation.password.short"),
                    visible: passwordVisited && !passwordFocused && !vm.password.isEmpty && vm.password.count < 6
                )
                .submitLabel(.go)
                .onSubmit {
                    Task {
                        await vm.login()
                        if vm.error == nil {
                            onSuccess()
                        }
                    }
                }
            }

            // MARK: – Кнопки действий
            VStack(spacing: 16) {
                PrimaryActionButton(
                    title: String(localized: "auth.login.signin"),
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
                            // отмена или другие ошибки обрабатываются в VM (popupClosedByUser игнорируется)
                        }
                    }
                }
                .frame(height: 44)
                .cornerRadius(8)
                .disabled(vm.isLoading)
                .accessibilityLabel(Text(String(localized: "auth.login.google_button")))
            }

            // MARK: – Индикатор загрузки
            if vm.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }

            // MARK: – Навигация Sign Up / Reset Password
            HStack {
                Button(String(localized: "auth.login.signup")) {
                    authRouter.path.append(.signUp)
                }
                .buttonStyle(.authSecondary)

                Spacer()

                Button(String(localized: "auth.login.forgot")) {
                    showReset = true
                }
                .buttonStyle(.authSecondary)
            }
            .font(.footnote)

            Spacer()
        }
        .padding(24)
        .alertLocalizedError($vm.error, title: String(localized: "auth.login.error.title"))
        .navigationTitle(String(localized: "auth.login.title"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showReset) {
            ResetPasswordView(vm: makeResetVM())
        }
    }
}
```

#### GoogleSignInCoordinator.swift
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

#### AuthRouter.swift
```swift
import SwiftUI

final class AuthRouter: ObservableObject {
    @Published var path: [AuthRoute] = []
}
```

#### RootView.swift
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
                VStack {
                    ProgressView()
                    Text(String(localized: "common.loading"))
                        .padding(.top, 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else if session.isAuthenticated {
                EditorView(
                    vm:       container.makeEditorViewModel(),
                    cameraAccess: container.cameraAccessService,
                    onLogout: onLogout
                )
            }
            else {
                AuthStackView(
                    container: container,
                    onLogin:   {  }
                )
            }
        }
        .environmentObject(session)
    }
}
```

---

## Архитектура приложения

### Основные принципы

1. **MVVM Architecture**: Разделение логики и представления через ViewModels
2. **Dependency Injection**: Централизованное управление зависимостями через `AppDependencyContainer`
3. **Protocol-Oriented Design**: Использование протоколов для абстракции сервисов
4. **Combine Framework**: Реактивное программирование для управления состоянием
5. **SwiftUI**: Современный декларативный UI фреймворк

### Потоки данных

1. **Аутентификация**: `FirebaseAuthService` → `SessionStore` → `RootView`
2. **Обработка изображений**: `ImagePipeline` → `EditorViewModel` → `EditorView`
3. **Экспорт**: `ExportService` → `EditorViewModel` → Share Sheet

### Ключевые компоненты

- **App Layer**: Инициализация приложения и конфигурация
- **Core Layer**: Бизнес-логика, модели, сервисы
- **Features Layer**: UI компоненты и ViewModels
- **Navigation Layer**: Управление навигацией между экранами

---

## Локализация

Проект поддерживает многоязычность через файлы:
- `Localizable.xcstrings` - основные строки
- `SimplePhotoEditor Localizations/` - переводы на английский и русский

---

## Зависимости

- Firebase Auth
- Google Sign-In
- SwiftUI
- Combine
- PencilKit
- PhotosUI
- CoreImage

---

*Последнее обновление: актуально на момент создания этого README*