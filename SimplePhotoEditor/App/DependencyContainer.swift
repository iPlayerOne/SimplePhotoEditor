import Foundation

@MainActor
final class AppDependencyContainer {

    // --- синглтоны сервисов ------------------------------------------
    private let authService:      AuthService
    private let exportService:    ExportService
    private let transformService: TransformService
    private let filterService:    FilterService
    private let composeService:   ImageComposeService
    private let textService:      TextOverlayService

    // --- инъекция конкретных реализаций ------------------------------
    init(
        authService:      AuthService       = FirebaseAuthService(),
        exportService:    ExportService     = ExportServiceImpl(),
        transformService: TransformService  = TransformServiceImpl(),
        filterService:    FilterService     = FilterServiceImpl(),
        composeService:   ImageComposeService = ImageComposeServiceImpl(),
        textService:      TextOverlayService = TextOverlayServiceImpl()
    ) {
        self.authService      = authService
        self.exportService    = exportService
        self.transformService = transformService
        self.filterService    = filterService
        self.composeService   = composeService
        self.textService      = textService
    }

    // MARK: – Auth -----------------------------------------------------
    func makeGoogleSignInCoordinator() -> GoogleSignInCoordinator {
        GoogleSignInCoordinatorImpl(clientID: AppConfig.googleClientID)
    }

    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(
            authService:       authService,
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
            filterService:    filterService,
            composeService:   composeService,
            textService:      textService,
            exportService:    exportService
            // previewRenderer по умолчанию — PreviewRenderServiceImpl()
        )
    }
}
