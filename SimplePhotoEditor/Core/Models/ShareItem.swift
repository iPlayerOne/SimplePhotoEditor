import UniformTypeIdentifiers
import SwiftUI

struct ShareItem: Identifiable, Equatable {
    let id: UUID = UUID()
    let image: UIImage
    static func == (lhs: ShareItem, rhs: ShareItem) -> Bool {
        lhs.id == rhs.id
    }
}
