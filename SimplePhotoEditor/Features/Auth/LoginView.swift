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

    // MARK: – Сброс пароля (sheet)
    @State private var showReset = false
    private let makeResetVM: () -> ResetPasswordViewModel

    /// Колбэк, вызываемый после успешного логина (чтобы поднять флаг в RootView)
    let onSuccess: () -> Void

    // Focus + visited для подсказок «после ухода фокуса»
    @FocusState private var emailFocused: Bool
    @FocusState private var passwordFocused: Bool
    @State private var emailVisited = false
    @State private var passwordVisited = false

    init(
        vm: LoginViewModel,
        googleCoordinator: GoogleSignInCoordinator,
        onSuccess: @escaping () -> Void,
        resetVMFactory: @escaping () -> ResetPasswordViewModel
    ) {
        _vm = StateObject(wrappedValue: vm)
        self.googleCoordinator = googleCoordinator
        self.onSuccess = onSuccess
        self.makeResetVM = resetVMFactory
    }

    var body: some View {
        VStack(spacing: 32) {
            Text("Welcome Back")
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 16) {
                // Email
                AuthTextField(
                    placeholder: "Email",
                    text: $vm.email,
                    keyboard: .emailAddress,
                    textContentType: .emailAddress,
                    isFocused: $emailFocused
                )
                .onChange(of: emailFocused) {
                    if !emailFocused { emailVisited = true }
                }
                .validationMessage(
                    "Enter a valid email.",
                    visible: emailVisited && !emailFocused && !vm.email.isEmpty && !EmailValidator.isValid(vm.email)
                )

                // Password
                AuthTextField(
                    placeholder: "Password (min 6)",
                    text: $vm.password,
                    isSecure: true,
                    textContentType: .password,
                    isFocused: $passwordFocused
                )
                .onChange(of: passwordFocused) {
                    if !passwordFocused { passwordVisited = true }
                }
                .validationMessage(
                    "Password is too short (min 6).",
                    visible: passwordVisited && !passwordFocused && !vm.password.isEmpty && vm.password.count < 6
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
                .buttonStyle(.authSecondary)

                Spacer()

                Button("Forgot Password?") {
                    showReset = true
                }
                .buttonStyle(.authSecondary)
            }
            .font(.footnote)

            Spacer()
        }
        .padding(24)
        .alertLocalizedError($vm.error, title: "Login Failed")
        .navigationTitle("Sign In")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showReset) {
            ResetPasswordView(vm: makeResetVM())
        }
    }
}
