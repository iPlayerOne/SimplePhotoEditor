import SwiftUI

// MARK: - Primary
struct AuthButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        let bg = isEnabled ? Color.accentColor : Color.accentColor.opacity(0.4)
        let fg = Color.white.opacity(isEnabled ? 1.0 : 0.7)

        return configuration.label
            .font(.headline)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .foregroundStyle(fg)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(bg)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.white.opacity(configuration.isPressed && isEnabled ? 0.2 : 0), lineWidth: 1)
            )
            .scaleEffect(configuration.isPressed && isEnabled ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
            .animation(.easeInOut(duration: 0.2), value: isEnabled)
            .accessibilityAddTraits(.isButton)
            .accessibilityHint(isEnabled ? "" : String(localized: "common.unavailable"))
    }
}

extension ButtonStyle where Self == AuthButtonStyle {
    static var authPrimary: AuthButtonStyle { .init() }
}

// MARK: - Secondary
struct AuthSecondaryButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        let fg = isEnabled ? Color.accentColor : Color.secondary.opacity(0.5)

        return configuration.label
            .font(.callout.weight(.semibold))
            .foregroundStyle(fg)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.clear)
            )
            .opacity(configuration.isPressed && isEnabled ? 0.7 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == AuthSecondaryButtonStyle {
    static var authSecondary: AuthSecondaryButtonStyle { .init() }
}
