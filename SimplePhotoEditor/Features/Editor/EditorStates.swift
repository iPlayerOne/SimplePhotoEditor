import Foundation

enum EditorMode: String, CaseIterable, Identifiable {
    case filter

    var id: Self { self }
    var iconName: String { "camera.filters" }
    var title:    String { "Фильтры" }
}

enum MarkupTool: CaseIterable, Identifiable {
    case none
    case draw
    case text

    var id: Self { self }

    var iconName: String {
        switch self {
        case .none:
            return ""
        case .draw:
            return "pencil.tip"
        case .text:
            return "textformat"
        }
    }

}
