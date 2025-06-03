import Foundation

struct Photo: Identifiable {
    let id: UUID = UUID()
    let imageData: Data
    let creationDate: Date
}
