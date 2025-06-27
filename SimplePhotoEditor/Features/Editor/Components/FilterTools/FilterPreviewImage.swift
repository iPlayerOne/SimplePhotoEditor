import SwiftUI

struct FilterPreviewImage: View, Equatable {
    let image: UIImage?
    let name: String
    let isSelected: Bool

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.image === rhs.image && lhs.isSelected == rhs.isSelected && lhs.name == rhs.name
    }

    var body: some View {
        VStack(spacing: 4) {
            Image(uiImage: image ?? UIImage())
                .resizable()
                .frame(width: 48, height: 48)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? .blue : .clear, lineWidth: 2)
                )
            Text(name)
                .font(.caption2)
                .foregroundColor(isSelected ? .accentColor : .primary)
                .lineLimit(1)
                .frame(width: 56)
        }
    }
}

struct FilteredImage: View {
    let baseImage: UIImage?
    let filterName: String

    var body: some View {
        if let baseImage {
            FilteredImageView(baseImage: baseImage, filterName: filterName)
        } else {
            Color.gray.opacity(0.2)
        }
    }
}

struct FilteredImageView: UIViewRepresentable {
    let baseImage: UIImage
    let filterName: String

    func makeUIView(context: Context) -> UIImageView {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        // Применяем фильтр через CoreImage
        DispatchQueue.global(qos: .userInitiated).async {
            let outputImage: UIImage
            if filterName.isEmpty {
                outputImage = baseImage
            } else if let ciImage = CIImage(image: baseImage),
                      let filter = CIFilter(name: filterName) {
                filter.setValue(ciImage, forKey: kCIInputImageKey)
                let context = CIContext()
                if let outputCIImage = filter.outputImage,
                   let cgImage = context.createCGImage(outputCIImage, from: outputCIImage.extent) {
                    outputImage = UIImage(cgImage: cgImage, scale: baseImage.scale, orientation: baseImage.imageOrientation)
                } else {
                    outputImage = baseImage // fallback
                }
            } else {
                outputImage = baseImage // fallback
            }
            DispatchQueue.main.async {
                uiView.image = outputImage
            }
        }
    }
} 