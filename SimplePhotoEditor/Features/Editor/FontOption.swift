import SwiftUI
import CoreText

enum FontOption: Hashable, Identifiable {
    case system, rounded, serif, monospaced
    case named(String) // PostScript name

    var id: String {
        switch self {
        case .system: "system"
        case .rounded: "rounded"
        case .serif: "serif"
        case .monospaced: "monospaced"
        case .named(let n): "named:\(n)"
        }
    }

    // Для UI (меню/превью в SwiftUI)
    var displayName: String {
        switch self {
        case .system:      return "System"
        case .rounded:     return "System Rounded"
        case .serif:       return "System Serif"
        case .monospaced:  return "System Monospaced"
        case .named(let ps):
            // Красивое (локализованное) имя, если доступно
            let ct = CTFontCreateWithName(ps as CFString, 17, nil)
            return (CTFontCopyDisplayName(ct) as String?) ?? ps
        }
    }

    func font(size: CGFloat) -> Font {
        switch self {
        case .system:     return .system(size: size)
        case .rounded:    return .system(size: size, design: .rounded)
        case .serif:      return .system(size: size, design: .serif)
        case .monospaced: return .system(size: size, design: .monospaced)
        case .named(let ps):
            return UIFont(name: ps, size: size).map(Font.init) ?? .system(size: size)
        }
    }

    // Мост для рендера (UIKit / NSAttributedString)
    func uiFont(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        switch self {
        case .system:
            return .systemFont(ofSize: size, weight: weight)
        case .rounded, .serif, .monospaced:
            // Официальный способ получить SF Rounded / New York / SF Mono
            let base = UIFont.systemFont(ofSize: size, weight: weight)
            let design: UIFontDescriptor.SystemDesign =
                (self == .rounded) ? .rounded :
                (self == .serif) ? .serif : .monospaced
            if let d = base.fontDescriptor.withDesign(design) {
                return UIFont(descriptor: d, size: size)
            }
            return base
        case .named(let ps):
            return UIFont(name: ps, size: size) ?? .systemFont(ofSize: size, weight: weight)
        }
    }
}
