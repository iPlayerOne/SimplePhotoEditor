import SwiftUI

struct ResetPasswordView: View {
    @StateObject var vm: ResetPasswordViewModel
    @Environment(\.dismiss) private var dismiss

    @FocusState private var emailFocused: Bool
    @State private var emailVisited = false

    var body: some View {
        VStack(spacing: 32) {
            Text(String(localized: "auth.reset.header"))
                .font(.largeTitle.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)

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

            PrimaryActionButton(
                title: String(localized: "auth.reset.send_link"),
                enabled: vm.canReset && !vm.isLoading
            ) {
                Task { await vm.resetPassword() }
            }

            if vm.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }

            Spacer()
        }
        .padding(24)
        .navigationTitle(String(localized: "auth.reset.title"))
        .navigationBarTitleDisplayMode(.inline)
        .alertLocalizedError($vm.error, title: String(localized: "common.error"))
        .alert(
            String(localized: "auth.registration.verification.title"),
            isPresented: $vm.didSend
        ) {
            Button(String(localized: "common.ok")) { dismiss() }
        } message: {
            Text(String(localized: "auth.reset.message"))
        }
    }
}
