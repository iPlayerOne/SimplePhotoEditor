import SwiftUI

struct AuthTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var isSecure: Bool = false
    var textContentType: UITextContentType? = nil
    var isFocused: FocusState<Bool>.Binding? = nil

    var body: some View {
        Group {
            if isSecure {
                if let isFocused {
                    SecureField(placeholder, text: $text)
                        .textContentType(textContentType)
                        .autocorrectionDisabled(true)
                        .focused(isFocused)
                } else {
                    SecureField(placeholder, text: $text)
                        .textContentType(textContentType)
                        .autocorrectionDisabled(true)
                }
            } else {
                if let isFocused {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboard)
                        .autocapitalization(.none)
                        .textContentType(textContentType)
                        .autocorrectionDisabled(true)
                        .focused(isFocused)
                } else {
                    TextField(placeholder, text: $text)
                        .keyboardType(keyboard)
                        .autocapitalization(.none)
                        .textContentType(textContentType)
                        .autocorrectionDisabled(true)
                }
            }
        }
        .authFieldStyle()
    }
}

#Preview {
    AuthTextField(placeholder: "Username", text: .constant("qwerty"), isSecure: true)
}
