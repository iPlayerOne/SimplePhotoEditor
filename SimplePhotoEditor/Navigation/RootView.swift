// Navigation/RootView.swift

import SwiftUI

struct RootView: View {
    @EnvironmentObject private var session: SessionStore
    let container:             AppDependencyContainer
    let onLogout:              () -> Void

    init(container: AppDependencyContainer, onLogout: @escaping () -> Void) {
        self.container = container
        self.onLogout  = onLogout
    }

    var body: some View {
        NavigationStack {
            if !session.didFinishChecking {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else if session.isAuthenticated {
                EditorView(
                    vm:       container.makeEditorViewModel(),
                    cameraAccess: container.cameraAccessService,
//                    onShare:  { Task { try? await container.makeEditorViewModel().exportFinalImage() } },
                    onLogout: onLogout
                )
            }
            else {
                AuthStackView(
                    container: container,
                    onLogin:   {  }
                )
            }
        }
        .environmentObject(session)
    }
}
