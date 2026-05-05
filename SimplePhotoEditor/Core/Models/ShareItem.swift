import Foundation

struct ShareItem: Identifiable, Equatable {
    let id: UUID = UUID()
    let url: URL

    static func == (lhs: ShareItem, rhs: ShareItem) -> Bool {
        lhs.id == rhs.id
    }
}
