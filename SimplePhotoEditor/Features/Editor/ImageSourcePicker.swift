import SwiftUI

struct ImageSourcePicker: View {
    let onCamera: () -> Void
    let onLibrary: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Text(String(localized: "editor.source.title"))
                .font(.headline)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)

            VStack(spacing: 12) {
                Button(action: onCamera) {
                    Text(String(localized: "editor.source.camera"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.sheetPrimaryGlass(isCancel: false))

                Button(action: onLibrary) {
                    Text(String(localized: "editor.source.gallery"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.sheetPrimaryGlass(isCancel: false))

                Button(action: onDismiss) {
                    Text(String(localized: "common.cancel"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.sheetPrimaryGlass(isCancel: true))
                .tint(.red)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(.systemBackground).ignoresSafeArea())

        .presentationDetents([.fraction(0.28), .medium])
        .presentationDragIndicator(.hidden)
        .presentationBackgroundInteraction(.enabled(upThrough: .fraction(0.28)))
    }
}

#Preview("ImageSourcePicker") {
    struct Host: View {
        @State private var isPresented = true
        var body: some View {
            Color.clear
                .sheet(isPresented: $isPresented) {
                    ImageSourcePicker(
                        onCamera:  { isPresented = false },
                        onLibrary: { isPresented = false },
                        onDismiss: { isPresented = false }
                    )
                }
        }
    }
    return Host()
}
