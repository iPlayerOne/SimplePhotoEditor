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
            .map { email, pass in
                EmailValidator.isValid(email) && pass.count >= 6
            }
            .assign(to: &$canSignIn)
    }

    func login() async {
        guard canSignIn else { return }
        isLoading = true; defer { isLoading = false }

        do {
            let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
            _ = try await authService.signIn(email: cleanEmail, password: password)
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
