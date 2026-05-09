import UIKit
import SwiftUI

enum DisplayScale {
    static let fallback: CGFloat = 2
}

@inline(__always)
func snapToPixel(_ v: CGFloat, scale: CGFloat = DisplayScale.fallback) -> CGFloat {
    (v * scale).rounded() / scale
}
