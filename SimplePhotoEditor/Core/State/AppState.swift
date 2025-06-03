import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?

    private var cancellables = Set<AnyCancellable>()
    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
        authService.authStatePublisher
//            .receive(on: DispatchQueue.main)
            .sink { [weak self] user in
                self?.currentUser     = user
                self?.isAuthenticated = (user != nil)
            }
            .store(in: &cancellables)
    }

    func logout() {
        do {
            try authService.signOut()
        } catch {
            print("Logout failed:", error)
        }
    }
}
