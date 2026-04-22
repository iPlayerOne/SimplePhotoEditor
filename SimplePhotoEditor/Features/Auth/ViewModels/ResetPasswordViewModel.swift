import Foundation
import Combine

@MainActor
class ResetPasswordViewModel: ObservableObject {
    @Published var email = ""
    @Published var isLoading = false
    @Published var error: AuthError?
    @Published var didSend = false
    @Published private(set) var canReset = false
    @Published private(set) var emailValidationMessage: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private let authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
        setupBinding()
    }
    
    private func setupBinding() {
        $email
            .map { raw -> Bool in
                let clean = raw.trimmingCharacters(in: .whitespacesAndNewlines)
                return !clean.isEmpty
            }
            .removeDuplicates()
            .assign(to: &$canReset)
        
        $email
            .map { raw -> String? in
                let clean = raw.trimmingCharacters(in: .whitespacesAndNewlines)
                
                guard !clean.isEmpty else { return nil }
                
                guard EmailValidator.isValid(clean) else {
                    return String(localized: "auth.validation.email.invalid")
                }
                return nil
            }
            .removeDuplicates()
            .assign(to: &$emailValidationMessage)
        
        $email
            .sink { [weak self] _ in
                self?.error = nil
            }
            .store(in: &cancellables)
    }
    
    func resetPassword() async {
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !cleanEmail.isEmpty else { return }
        
        guard EmailValidator.isValid(cleanEmail) else {
            emailValidationMessage = String(localized: "auth.validation.email.invalid")
            return
        }
        
        guard !isLoading else { return }
        
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
