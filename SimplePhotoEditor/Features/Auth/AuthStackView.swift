import SwiftUI

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
            LoginView(
                vm: container.makeLoginViewModel(),
                googleCoordinator: container.googleCoordinator,
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
