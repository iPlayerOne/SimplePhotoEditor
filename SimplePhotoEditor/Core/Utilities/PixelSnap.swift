import UIKit
import SwiftUI

@inline(__always)
func snapToPixel(_ v: CGFloat, scale: CGFloat = UIScreen.main.scale) -> CGFloat {
    (v * scale).rounded() / scale
}

