import SwiftUI

struct PhotoLayer: View {
    let image:   UIImage?
    let maxSize: CGSize
    var onAddImage: (() -> Void)? = nil

    var body: some View {
        Group {
            if let ui = image {
                Image(uiImage: ui)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Button(action: { onAddImage?() }) {
                    VStack(spacing: 12) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 56, height: 56)
                            .foregroundColor(.accentColor)
                        Text("Добавить изображение")
                            .font(.headline)
                            .foregroundColor(.accentColor)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.secondary.opacity(0.08))
                    .cornerRadius(16)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .frame(width: maxSize.width, height: maxSize.height)
        .clipped()
    }
}
