import UIKit
import SwiftUI

@inline(__always)
func snapToPixel(_ v: CGFloat, scale: CGFloat = UIScreen.main.scale) -> CGFloat {
    (v * scale).rounded() / scale
}

extension View {
    func hideHorizontalSeam() -> some View {
        let eps = 1 / UIScreen.main.scale
        return self.padding(.horizontal, -eps / 2)
    }
}
