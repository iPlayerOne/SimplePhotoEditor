// Features/Auth/LoginView.swift

import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    // MARK: – Навигация внутри Auth
    @EnvironmentObject private var authRouter: AuthRouter

    // MARK: – ViewModel
    @StateObject private var vm: LoginViewModel

    // MARK: – Google Sign-In Coordinator
    let googleCoordinator: GoogleSignInCoordinator

    /// Колбэк, вызываемый после успешного логина (чтобы поднять флаг в RootView)
    let onSuccess: () -> Void

    init(
        vm: LoginViewModel,
        googleCoordinator: GoogleSignInCoordinator,
        onSuccess: @escaping () -> Void
    ) {
        _vm = StateObject(wrappedValue: vm)
        self.googleCoordinator = googleCoordinator
        self.onSuccess = onSuccess
    }

    var body: some View {
        VStack(spacing: 32) {
            Text("Welcome Back")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(spacing: 16) {
                AuthTextField(
                    placeholder: "Email",
                    text: $vm.email,
                    keyboard: .emailAddress
                )
                AuthTextField(
                    placeholder: "Password (min 6)",
                    text: $vm.password,
                    isSecure: true
                )
            }

            // MARK: – Кнопки действий
            VStack(spacing: 16) {
                PrimaryActionButton(
                    title: "Sign In",
                    enabled: vm.canSignIn
                ) {
                    Task {
                        await vm.login()
                        if vm.error == nil {
                            onSuccess()
                        }
                    }
                }

                GoogleSignInButton {
                    Task {
                        do {
                            let (idToken, accessToken) = try await
                                googleCoordinator.signIn()
                            await vm.loginWithGoogle(
                                idToken:     idToken,
                                accessToken: accessToken
                            )
                            if vm.error == nil {
                                onSuccess()
                            }
                        } catch {
                            // отмена или ошибки обработать при необходимости
                        }
                    }
                }
                .frame(height: 44)
                .cornerRadius(8)
                .disabled(vm.isLoading)
            }

            // MARK: – Индикатор загрузки
            if vm.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }

            // MARK: – Навигация Sign Up / Reset Password
            HStack {
                Button("Sign Up") {
                    authRouter.path.append(.signUp)
                }
                Spacer()
                Button("Forgot Password?") {
                    authRouter.path.append(.resetPassword)
                }
            }
            .font(.footnote)
            .foregroundColor(.secondary)

            Spacer()
        }
        .padding(24)
        .alertLocalizedError($vm.error, title: "Login Failed")
        .navigationTitle("Sign In")
        .navigationBarTitleDisplayMode(.inline)
    }
}
