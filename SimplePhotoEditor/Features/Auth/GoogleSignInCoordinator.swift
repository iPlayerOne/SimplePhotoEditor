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
