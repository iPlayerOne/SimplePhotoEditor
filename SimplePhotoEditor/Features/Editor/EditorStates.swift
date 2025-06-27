import Foundation

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
