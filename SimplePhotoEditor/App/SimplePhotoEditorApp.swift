import SwiftUI
import GoogleSignIn

@main
struct SimplePhotoEditorApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var session: SessionStore
    private let container: AppDependencyContainer

    init() {
        AppConfig.setupFirebase()
        let authService = FirebaseAuthService()
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
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
    }
}
