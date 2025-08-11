import Foundation

@MainActor
final class AppDependencyContainer {

    private let transformService = TransformServiceImpl()
    private let filterService    = FilterServiceImpl()
    private let overlayService   = OverlayRenderServiceImpl()
    private let decodeService    = ImageDecodeServiceImpl()
    private let previewService   = PreviewRenderServiceImpl()
    private let exportService    = ExportServiceImpl()

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
