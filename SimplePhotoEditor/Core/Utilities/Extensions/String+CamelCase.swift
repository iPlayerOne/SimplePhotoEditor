import Foundation

extension String {
    func camelCaseToWords(removing prefix: String = "") -> String {
        let base = hasPrefix(prefix) ? String(dropFirst(prefix.count)) : self
        let pattern = "([a-z0-9])([A-Z])"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return base }
        let range = NSRange(base.startIndex..<base.endIndex, in: base)
        let result = regex.stringByReplacingMatches(
            in: base,
            options: [],
            range: range,
            withTemplate: "$1 $2"
        )
        return result
    }
}

