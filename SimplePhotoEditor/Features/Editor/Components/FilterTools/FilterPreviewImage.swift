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

