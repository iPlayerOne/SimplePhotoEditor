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
                let iw = ui.size.width
                let ih = ui.size.height
                let mode = (contentMode == .fit) ? "fit" : "fill"

                Image(uiImage: ui)
                    .interpolation(.none)
                    .antialiased(false)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .frame(width: w, height: h)
                    .clipped()
                    #if DEBUG
                    .overlay(
                        Rectangle()
                            .stroke(Color.red.opacity(0.6), lineWidth: 1)
                    )
                    .onAppear {
                        print("🖼 PhotoLayer appear: mode=\(mode), container=\(maxSize) snapped=(\(w.rounded()),\(h.rounded())) image=\(CGSize(width: iw, height: ih)) scale=\(scale)")
                    }
                    .onChange(of: maxSize) { new in
                        let sw = snapToPixel(new.width, scale: scale)
                        let sh = snapToPixel(new.height, scale: scale)
                        print("🖼 PhotoLayer size change: mode=\(mode), container=\(new) snapped=(\(sw.rounded()),\(sh.rounded())) image=\(CGSize(width: iw, height: ih))")
                    }
                    #endif
            } else if let onAddImage {
                Button(action: onAddImage) {
                    placeholder
                }
                .buttonStyle(.glass)
                .frame(width: w, height: h)
                #if DEBUG
                .overlay(
                    Rectangle()
                        .stroke(Color.orange.opacity(0.6), lineWidth: 1)
                )
                #endif
            } else {
                placeholder
                    #if DEBUG
                    .overlay(
                        Rectangle()
                            .stroke(Color.orange.opacity(0.6), lineWidth: 1)
                    )
                    #endif
            }
        }
        .frame(width: maxSize.width, height: maxSize.height, alignment: .center)
        #if DEBUG
        .background(Color.yellow.opacity(0.03))
        .overlay(
            Rectangle()
                .stroke(Color.blue.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
        )
        #endif
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
