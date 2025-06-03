// App/SimplePhotoEditorApp.swift

import SwiftUI
import FirebaseCore

@main
struct SimplePhotoEditorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var session: SessionStore
    private let container: AppDependencyContainer

    init() {
        // --- ОБЯЗАТЕЛЬНО первым делом на старте ---
        FirebaseApp.configure()

        // Создаём единый инстанс AuthService
        let authService = FirebaseAuthService()
        // Передаём его и в SessionStore, и в DI-контейнер
        let sessionStore = SessionStore(authService: authService)
        _session = StateObject(wrappedValue: sessionStore)
        container = AppDependencyContainer(authService: authService)
    }

    var body: some Scene {
        WindowGroup {
            RootView(
                container: container,
                onLogout:  { session.logout() }
            )
            .environmentObject(session)
        }
    }
}
