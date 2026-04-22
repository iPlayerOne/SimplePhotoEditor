import Foundation

@MainActor
final class AppDependencyContainer {

    private let transformService = TransformServiceImpl()
    private let filterService    = FilterServiceImpl()
    private let overlayService   = OverlayRenderServiceImpl()
    private let decodeService    = ImageDecodeServiceImpl()
    private let exportService    = ExportServiceImpl()
    
    let cameraAccessService: CameraAccess = CameraAccessService()
    let imageImportService: ImageImportService = ImageImportServiceImpl()

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
        _ = CIContextPool.final
        _ = CIContextPool.preview
        
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
            textVM: makeTextOverlayViewModel(),
            imageImportService: imageImportService
        )
    }

    func makeTextOverlayViewModel() -> TextOverlayViewModel {
        TextOverlayViewModel()
    }
}
