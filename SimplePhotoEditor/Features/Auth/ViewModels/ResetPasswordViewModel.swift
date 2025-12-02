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
        setupBinding()
    }
    
    private func setupBinding() {
        $email
            .map { EmailValidator.isValid($0) }
            .removeDuplicates()
            .assign(to: &$canReset)
        $email
            .sink { [weak self] _ in
                self?.error = nil
            }
            .store(in: &cancellables)
    }
    
    func resetPassword() async {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard EmailValidator.isValid(cleanEmail) else {
            self.error = .invalidEmailFormat
            return
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await authService.resetPassword(email: cleanEmail)
            didSend = true
        } catch let err as AuthError {
            self.error = err
        } catch {
            self.error = .networkError(underlying: error)
        }
    }
}
