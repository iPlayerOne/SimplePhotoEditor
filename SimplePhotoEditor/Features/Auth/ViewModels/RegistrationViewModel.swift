import Foundation
import Combine

@MainActor
final class RegistrationViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    
    @Published var isLoading = false
    @Published var error: AuthError?
    @Published var didRegister = false
    
    @Published private(set) var canRegister = false
    
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()
    init(authService: AuthService) {
        self.authService = authService
        setupBindings()
    }
    
    private func setupBindings() {
        $email
            .combineLatest($password, $confirmPassword)
            .map { email, pass, confirm in
                let hasEmail  = !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                let hasPass   = pass.count >= 6
                let matches   = !pass.isEmpty && pass == confirm
                return hasEmail && hasPass && matches
            }
            .removeDuplicates()
            .assign(to: &$canRegister)
        
        Publishers.Merge3($email, $password, $confirmPassword)
            .sink { [weak self] _ in
                self?.error = nil
            }
            .store(in: &cancellables)
    }
    
    func register() async {
        guard canRegister else { return }
        isLoading = true
        
        do {
            let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
            _ = try await authService.register(email: cleanEmail, password: password)
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
