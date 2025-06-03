import Foundation
import Combine

@MainActor
class ResetPasswordViewModel: ObservableObject {
    @Published var email = ""

    @Published var isLoading = false
    @Published var error: AuthError?
    @Published var didSend = false
    @Published private(set) var canReset = false

    private var cancellables = Set<AnyCancellable>()
    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService

        $email
            .map { $0.contains("@") && $0.contains(".") }
            .assign(to: &$canReset)
    }

    func resetPassword() async {
        guard canReset else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            try await authService.resetPassword(email: email)
            didSend = true
        } catch let err as AuthError {
            self.error = err
        } catch {
            self.error = .networkError(underlying: error)
        }
    }
}
