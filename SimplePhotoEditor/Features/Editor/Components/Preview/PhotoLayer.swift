import SwiftUI

struct PhotoLayer: View {
    let image:   UIImage?
    let maxSize: CGSize
    let onAddImage: (() -> Void)?
    
    let contentMode: ContentMode
    let cornerRadius: CGFloat
    let placeholderBackground: Color
    let placeholderIconName: String
    let placeholderText: String
    
    init(
        image: UIImage?,
        maxSize: CGSize,
        onAddImage: (() -> Void)? = nil,
        contentMode: ContentMode = .fit,
        cornerRadius: CGFloat = 16,
        placeholderBackground: Color = .secondary.opacity(0.08),
        placeholderIconName: String = "photo.on.rectangle.angled",
        placeholderText: String = "Добавить изображение"
    ) {
        self.image = image
        self.maxSize = maxSize
        self.onAddImage = onAddImage
        self.contentMode = contentMode
        self.cornerRadius = cornerRadius
        self.placeholderBackground = placeholderBackground
        self.placeholderIconName = placeholderIconName
        self.placeholderText = placeholderText
    }
    
    var body: some View {
        let scale = UIScreen.main.scale
        let w = snapToPixel(maxSize.width, scale: scale)
        let h = snapToPixel(maxSize.height, scale: scale)
        
        Group {
            if let ui = image {
                Image(uiImage: ui)
                    .interpolation(.none)
                    .antialiased(false)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .frame(width: w, height: h)
                    .clipped()
            } else if let onAddImage {
                Button(action: onAddImage) {
                    placeholder
                }
                .buttonStyle(.glass)
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
    
//    @ViewBuilder
//    private var content: some View {
//        if let ui = image {
//            Image(uiImage: ui)
//                .interpolation(.none)
//                .antialiased(false)
//                .resizable()
//                .aspectRatio(contentMode: contentMode)
//                .frame(width: maxSize.width, height: maxSize.height)
//                .clipped()
//        } else if let onAddImage {
//            Button(action: onAddImage) {
//                placeholder
//            }
//            .buttonStyle(.plain)
//        } else {
//            placeholder
//        }
//    }
    
//    private var placeholder: some View {
//        VStack(spacing: 12) {
//            Image(systemName: placeholderIconName)
//                .resizable()
//                .scaledToFit()
//                .frame(width: 56, height: 56)
//                .foregroundStyle(.tint)
//            Text(placeholderText)
//                .font(.headline)
//                .foregroundStyle(.tint)
//        }
//        .frame(width: maxSize.width, height: maxSize.height)
//        .background(placeholderBackground)
    }
    
}
