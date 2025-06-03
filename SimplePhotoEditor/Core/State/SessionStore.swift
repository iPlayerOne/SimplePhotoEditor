import Foundation
import Combine
import FirebaseAuth

@MainActor
final class SessionStore: ObservableObject {
    @Published var isAuthenticated: Bool
    @Published var didFinishChecking = false

    private let authService: AuthService
    private var cancellable: AnyCancellable?

    init(authService: AuthService = FirebaseAuthService()) {
        self.authService = authService
        // синхронный старт
        let initial = Auth.auth().currentUser != nil
        self.isAuthenticated = initial

        // последующий контроль
        cancellable = authService.authStatePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.isAuthenticated     = (user != nil)
                self?.didFinishChecking   = true
            }
    }

    func logout() {
        try? authService.signOut()
    }
}

