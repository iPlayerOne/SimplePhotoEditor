import SwiftUI

struct RegistrationView: View {
    @StateObject var vm: RegistrationViewModel
    @EnvironmentObject var router: AuthRouter

    var body: some View {
        VStack(spacing: 32) {
            Text("Создать аккаунт")
                .font(.largeTitle.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)

            AuthTextField(
                placeholder: "Электронная почта",
                text: $vm.email,
                keyboard: .emailAddress,
                textContentType: .emailAddress
            )

            AuthTextField(
                placeholder: "Пароль (мин. 6 символов)",
                text: $vm.password,
                isSecure: true,
                textContentType: .newPassword
            )

            AuthTextField(
                placeholder: "Повторите пароль",
                text: $vm.repeatPassword,
                isSecure: true,
                textContentType: .newPassword
            )

            PrimaryActionButton(
                title: "Зарегистрироваться",
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
        .navigationTitle("Регистрация")
        .navigationBarTitleDisplayMode(.inline)
        // Показываем ошибку из vm.error
        .alertLocalizedError($vm.error, title: "Ошибка регистрации")
        // После успешной регистрации — уведомление и возврат назад
        .alert("Письмо отправлено",
               isPresented: $vm.didRegister) {
            Button("OK") {
                router.path.removeLast()
            }
        } message: {
            Text("Пожалуйста, подтвердите свою почту в письме.")
        }
    }
}
