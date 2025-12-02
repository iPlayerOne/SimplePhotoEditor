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
        
        setupBindings()

    }
    
    private func setupBindings() {
        Publishers.CombineLatest($email, $password)
            .map { email, pass in
                EmailValidator.isValid(email) && pass.count >= 6
            }
            .removeDuplicates()
            .assign(to: &$canSignIn)
        
        Publishers.Merge(
            $email.map { _ in () },
            $password.map { _ in () }
        )
        .sink { [weak self] _ in
            self?.error = nil
        }
        .store(in: &cancellables)
    }

    func login() async {
        guard canSignIn else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
            _ = try await authService.signIn(email: cleanEmail, password: password)
        } catch let err as AuthError {
            self.error = err
        } catch {
            self.error = .networkError(underlying: error)
        }
    }

    func loginWithGoogle() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let tokens = try await googleCoordinator.signIn()
            
            _ = try await authService.signInWithGoogle(
                idToken:     tokens.idToken,
                accessToken: tokens.accessToken
            )
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
