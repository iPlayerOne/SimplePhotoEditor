import SwiftUI
import GoogleSignInSwift

struct LoginView: View {
    @StateObject private var vm: LoginViewModel
    
    @State private var showReset = false
    @State private var emailVisited = false
    @State private var passwordVisited = false
    
    @FocusState private var emailFocused: Bool
    @FocusState private var passwordFocused: Bool
    
    @EnvironmentObject private var authRouter: AuthRouter
    private let makeResetVM: () -> ResetPasswordViewModel
    let onSuccess: () -> Void
    
    init(
        vm: LoginViewModel,
        onSuccess: @escaping () -> Void,
        resetVMFactory: @escaping () -> ResetPasswordViewModel
    ) {
        _vm = StateObject(wrappedValue: vm)
        self.onSuccess = onSuccess
        self.makeResetVM = resetVMFactory
    }
    
    var body: some View {
        VStack(spacing: 32) {
            Text(String(localized: "auth.login.header"))
                .font(.largeTitle)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 16) {
                AuthTextField(
                    placeholder: String(localized: "auth.email.placeholder"),
                    text: $vm.email,
                    keyboard: .emailAddress,
                    textContentType: .emailAddress,
                    isFocused: $emailFocused
                )
                .onChange(of: emailFocused) {
                    if !emailFocused { emailVisited = true }
                }
                .validationMessage(
                    String(localized: "auth.validation.email.invalid"),
                    visible: emailVisited && !emailFocused && !vm.email.isEmpty && !EmailValidator.isValid(vm.email)
                )
                .submitLabel(.next)
                .onSubmit {
                    passwordFocused = true
                }
                
                AuthTextField(
                    placeholder: String(localized: "auth.password.placeholder"),
                    text: $vm.password,
                    isSecure: true,
                    textContentType: .password,
                    isFocused: $passwordFocused
                )
                .onChange(of: passwordFocused) {
                    if !passwordFocused { passwordVisited = true }
                }
                .validationMessage(
                    String(localized: "auth.validation.password.short"),
                    visible: passwordVisited && !passwordFocused && !vm.password.isEmpty && vm.password.count < 6
                )
                .submitLabel(.go)
                .onSubmit {
                    Task {
                        await vm.login()
                        if vm.error == nil {
                            onSuccess()
                        }
                    }
                }
            }
            
            VStack(spacing: 16) {
                PrimaryActionButton(
                    title: String(localized: "auth.login.signin"),
                    enabled: vm.canSignIn && !vm.isLoading
                ) {
                    Task {
                        await vm.login()
                        if vm.error == nil {
                            onSuccess()
                        }
                    }
                }
                
                GoogleSignInButton(style: .wide) {
                    Task {
                            await vm.loginWithGoogle()
                            if vm.error == nil {
                                onSuccess()
                            }
                    }
                }
                .frame(height: 44)
                .disabled(vm.isLoading)
            }
            
            if vm.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }
            
            HStack {
                Button(String(localized: "auth.login.signup")) {
                    authRouter.path.append(.signUp)
                }
                .buttonStyle(.authSecondary)
                
                Spacer()
                
                Button(String(localized: "auth.login.forgot")) {
                    showReset = true
                }
                .buttonStyle(.authSecondary)
            }
            .font(.footnote)
            
            Spacer()
        }
        .padding(24)
        .alertLocalizedError($vm.error, title: String(localized: "auth.login.error.title"))
        .navigationTitle(String(localized: "auth.login.title"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showReset) {
            ResetPasswordView(vm: makeResetVM())
                .presentationDetents([.fraction(0.35), .medium])
                .presentationDragIndicator(.visible)
        }
    }
}
