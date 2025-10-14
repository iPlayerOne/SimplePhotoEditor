import Foundation
import Combine
import FirebaseAuth

@MainActor
class RegistrationViewModel: ObservableObject {
    @Published var email          = ""
    @Published var password       = ""
    @Published var repeatPassword = ""
    
    @Published var isLoading      = false
    @Published var error: AuthError?
    @Published var didRegister    = false
    
    @Published private(set) var canRegister = false
    
    private var cancellables = Set<AnyCancellable>()
    private let authService: AuthService
    
    init(authService: AuthService) {
        self.authService = authService
        
        Publishers.CombineLatest3($email, $password, $repeatPassword)
            .map { email, pwd, rep in
                // Используем единый валидатор EmailValidator.isValid
                let emailOK = EmailValidator.isValid(email)
                let pwdOK   = pwd.count >= 6
                let match   = pwd == rep
                return emailOK && pwdOK && match
            }
            .assign(to: &$canRegister)
    }
    
    func register() async {
        guard canRegister else { return }
        isLoading = true
        
        do {
            let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
            _ = try await authService.register(email: cleanEmail, password: password)
            // sendEmailVerification вызывается внутри FirebaseAuthService.register
            didRegister = true
        }
        catch let err as AuthError {
            self.error = err
        }
        catch {
            self.error = .networkError(underlying: error)
        }
        
        isLoading = false
    }
}
