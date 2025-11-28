import Foundation

@MainActor
final class AppDependencyContainer {

    private let transformService = TransformServiceImpl()
    private let filterService    = FilterServiceImpl()
    private let overlayService   = OverlayRenderServiceImpl()
    private let decodeService    = ImageDecodeServiceImpl()
    private let exportService    = ExportServiceImpl()
    
    let cameraAccessService: CameraAccess = CameraAccessService()

    private lazy var imagePipeline: ImagePipeline = {
        ImagePipelineImpl(
            decode: decodeService,
            transform: transformService,
            filter: filterService,
            overlay: overlayService
        )
    }()

    let authService: AuthService
    let googleCoordinator: GoogleSignInCoordinator

    init(authService: AuthService = FirebaseAuthService()) {
        _ = CIContextPool.shared
        self.authService = authService
        self.googleCoordinator = GoogleSignInCoordinatorImpl(
            clientID: AppConfig.googleClientID
        )
    }


    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(
            authService: authService,
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
            pipeline: imagePipeline,
            exportService: exportService,
            textVM: makeTextOverlayViewModel()
        )
    }

    func makeTextOverlayViewModel() -> TextOverlayViewModel {
        TextOverlayViewModel()
    }
}
