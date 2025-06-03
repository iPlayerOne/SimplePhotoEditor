import SwiftUI

struct PrimaryActionButton: View {
    let title: String
    let enabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.authPrimary)
        .disabled(!enabled)
    }
}

#Preview {
    PrimaryActionButton(title: "Test", enabled: true, action: {})
}
