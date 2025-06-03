import SwiftUI

struct ModeButton<Mode: Hashable>: View {
    @Binding var current: Mode
    let target: Mode
    let systemName: String
    let title: String?
    let widthFraction: CGFloat

    init(
        current: Binding<Mode>,
        target: Mode,
        systemName: String,
        title: String? = nil,
        widthFraction: CGFloat = 1.0
    ) {
        self._current = current
        self.target = target
        self.systemName = systemName
        self.title = title
        self.widthFraction = widthFraction
    }

    var body: some View {
        Button {
            current = target
        } label: {
            VStack(spacing: title == nil ? 0 : 4) {
                Image(systemName: systemName)
                    .font(.title2)
                if let title = title {
                    Text(title)
                        .font(.footnote)
                }
            }
            .foregroundColor(current == target ? .accentColor : .secondary)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .underline(
                selected: current == target,
                color: .accentColor,
                widthFraction: widthFraction,
                height: 2
            )
        }
        .buttonStyle(.plain)
    }
}
