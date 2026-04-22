import SwiftUI

struct RegistrationView: View {
    @StateObject var vm: RegistrationViewModel
    @EnvironmentObject var router: AuthRouter

    @FocusState private var emailFocused: Bool
    @FocusState private var passwordFocused: Bool
    @FocusState private var repeatFocused: Bool

    @State private var emailVisited = false
    @State private var passwordVisited = false
    @State private var repeatVisited = false

    var body: some View {
        VStack(spacing: 32) {
            Text(String(localized: "auth.registration.header"))
                .font(.largeTitle.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            AuthTextField(
                placeholder: String(localized: "auth.email.placeholder"),
                text: $vm.email,
                keyboard: .emailAddress,
                textContentType: .emailAddress
            )
            .focused($emailFocused)
            .onChange(of: emailFocused) { isFocused in
                if !isFocused { emailVisited = true }
            }
            .validationMessage(
                String(localized: "auth.validation.email.invalid"),
                visible: emailVisited
                    && !emailFocused
                    && !vm.email.isEmpty
                    && !EmailValidator.isValid(vm.email)
            )

            AuthTextField(
                placeholder: String(localized: "auth.password.placeholder"),
                text: $vm.password,
                isSecure: true,
                textContentType: .newPassword
            )
            .focused($passwordFocused)
            .onChange(of: passwordFocused) { isFocused in
                if !isFocused { passwordVisited = true }
            }
            .validationMessage(
                String(localized: "auth.validation.password.short"),
                visible: passwordVisited
                    && !passwordFocused
                    && !vm.password.isEmpty
                    && vm.password.count < 6
            )

            AuthTextField(
                placeholder: String(localized: "auth.password.repeat.placeholder"),
                text: $vm.confirmPassword,
                isSecure: true,
                textContentType: .newPassword
            )
            .focused($repeatFocused)
            .onChange(of: repeatFocused) { isFocused in
                if !isFocused { repeatVisited = true }
            }
            .validationMessage(
                String(localized: "auth.validation.password.mismatch"),
                visible: repeatVisited
                    && !repeatFocused
                    && !vm.confirmPassword.isEmpty
                    && vm.password != vm.confirmPassword
            )

            PrimaryActionButton(
                title: String(localized: "auth.registration.button"),
                enabled: vm.canRegister
            ) {
                Task { await vm.register() }
            }

            if vm.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }

            Spacer()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationTitle(String(localized: "auth.registration.title"))
        .navigationBarTitleDisplayMode(.inline)
        .alertLocalizedError($vm.error, title: String(localized: "auth.registration.error.title"))
        .alert(String(localized: "auth.registration.verification.title"),
               isPresented: $vm.didRegister) {
            Button(String(localized: "common.ok")) {
                router.path.removeLast()
            }
        } message: {
            Text(String(localized: "auth.registration.verification.message"))
        }
    }
}
