import SwiftUI

struct PhotoLayer: View {
    @Environment(\.displayScale) private var displayScale

    let image:   UIImage?
    let maxSize: CGSize
    let onAddImage: (() -> Void)?
    
    let contentMode: ContentMode
    let placeholderIconName: String
    let placeholderText: String
    
    init(
        image: UIImage?,
        maxSize: CGSize,
        onAddImage: (() -> Void)? = nil,
        contentMode: ContentMode = .fit,
        placeholderIconName: String = "photo.on.rectangle.angled",
        placeholderText: String = String(localized: "editor.photo.placeholder")
    ) {
        self.image = image
        self.maxSize = maxSize
        self.onAddImage = onAddImage
        self.contentMode = contentMode
        self.placeholderIconName = placeholderIconName
        self.placeholderText = placeholderText
    }
    
    var body: some View {
        let scale = displayScale
        let w = snapToPixel(maxSize.width, scale: scale)
        let h = snapToPixel(maxSize.height, scale: scale)

        Group {
            if let ui = image {
                Image(uiImage: ui)
                    .interpolation(.high)
                    .antialiased(true)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .frame(width: w, height: h)
                    .clipped()
            } else if let onAddImage {
                Button(action: onAddImage) {
                    placeholder
                }
                .buttonStyle(.plain)
                .frame(width: w, height: h)
            } else {
                placeholder
            }
        }
        .frame(width: maxSize.width, height: maxSize.height, alignment: .center)
    }
    
    private var placeholder: some View {
        VStack(spacing: 12) {
            Image(systemName: placeholderIconName)
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)
                .foregroundStyle(.tint)
            Text(placeholderText)
                .font(.headline)
                .foregroundStyle(.tint)
        }
    }
}
