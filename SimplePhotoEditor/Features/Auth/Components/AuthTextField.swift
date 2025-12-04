import SwiftUI

struct AuthTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var isSecure: Bool = false
    var textContentType: UITextContentType? = nil

    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .textContentType(textContentType)
                    .autocorrectionDisabled(true)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboard)
                    .autocapitalization(.none)
                    .textContentType(textContentType)
                    .autocorrectionDisabled(true)
            }
        }
        .authFieldStyle()
    }
}

#Preview {
    AuthTextField(
        placeholder: "Username",
        text: .constant("qwerty"),
        isSecure: false
    )
}
