import SwiftUI

struct FilterPreviewImage: View, Equatable {
    let image: UIImage?
    let name: String
    let isSelected: Bool
    let size: CGFloat

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.image === rhs.image && lhs.isSelected == rhs.isSelected && lhs.name == rhs.name
    }

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    ProgressView()
                }
            }
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay(Circle().stroke(.white.opacity(0.55), lineWidth: 1))
            .overlay {
                if isSelected { Circle().stroke(.tint, lineWidth: 3) }
            }

            Text(name)
                .font(.caption2)
                .lineLimit(1)
        }
        .frame(width: size + 18)
    }
}

