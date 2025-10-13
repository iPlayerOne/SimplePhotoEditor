import SwiftUI

struct ResetPasswordView: View {
    @StateObject var vm: ResetPasswordViewModel
    @Environment(\.dismiss) private var dismiss

    @FocusState private var emailFocused: Bool
    @State private var emailVisited = false

    var body: some View {
        VStack(spacing: 32) {
            // Заголовок экрана
            Text("Восстановление пароля")
                .font(.largeTitle.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            // Поле для email
            AuthTextField(
                placeholder: "Электронная почта",
                text: $vm.email,
                keyboard: .emailAddress,
                textContentType: .emailAddress,
                isFocused: $emailFocused
            )
            .onChange(of: emailFocused) {
                if !emailFocused { emailVisited = true }
            }
            .validationMessage(
                "Введите корректный email.",
                visible: emailVisited && !emailFocused && !vm.email.isEmpty && !EmailValidator.isValid(vm.email)
            )

            // Кнопка отправки
            PrimaryActionButton(
                title: "Отправить ссылку",
                enabled: vm.canReset
            ) {
                Task { await vm.resetPassword() }
            }

            // Индикатор загрузки
            if vm.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
            }

            Spacer()
        }
        .padding(24)
        .navigationTitle("Забыли пароль?")
        .navigationBarTitleDisplayMode(.inline)
        // Ошибки авторизации
        .alertLocalizedError($vm.error, title: "Ошибка")
        // Успешная отправка
        .alert(
            "Письмо отправлено",
            isPresented: $vm.didSend
        ) {
            Button("OK") { dismiss() }
        } message: {
            Text("Проверьте вашу почту для дальнейших инструкций.")
        }
    }
}
