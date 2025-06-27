import Foundation

struct Filter: Identifiable, Equatable {
    let id: UUID
    let name: String
    let filterName: String

    static var none: Filter {
        Filter(id: UUID(), name: "Нет", filterName: "")
    }
    var isNone: Bool { filterName.isEmpty }

    init(id: UUID = UUID(), name: String, filterName: String) {
        self.id = id
        self.name = name
        self.filterName = filterName
    }
}
