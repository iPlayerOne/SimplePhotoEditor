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
                let emailOK = email.contains("@") && email.contains(".")
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
            _ = try await authService.register(email: email, password: password)
            // если успешно — покажем алерт
            didRegister = true
        }
        catch let err as AuthError {
            // перехватываем конкретную ошибку «email уже занят»
            self.error = err
        }
        catch {
            // всё остальное как сетевые сбои
            self.error = .networkError(underlying: error)
        }
        
        isLoading = false
    }
}
