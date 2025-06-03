import SwiftUI

struct AuthButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.accentColor)
                    .opacity(configuration.isPressed ? 0.7 : 1)
            )
            .foregroundColor(.white)
    }
}

extension ButtonStyle where Self == AuthButtonStyle {
    static var authPrimary: AuthButtonStyle { .init() }
}
