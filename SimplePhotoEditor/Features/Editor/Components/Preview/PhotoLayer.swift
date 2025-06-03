import SwiftUI

struct PhotoLayer: View {
    let image:   UIImage?
    let maxSize: CGSize

    var body: some View {
        Group {
            if let ui = image {
                Image(uiImage: ui)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                
            } else {
                Color.secondary.opacity(0.1)
                    .overlay(Text("Нет изображения").foregroundColor(.secondary))
            }
        }
        .frame(width: maxSize.width, height: maxSize.height)
        .clipped()
    }
}
