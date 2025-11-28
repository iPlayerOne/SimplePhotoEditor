import SwiftUI
import UIKit

struct KeyboardAccessory<Content: View>: UIViewControllerRepresentable {
    let content: Content

    func makeUIViewController(context: Context) -> AccessoryHostingController<Content> {
        AccessoryHostingController(rootView: content)
    }

    func updateUIViewController(_ vc: AccessoryHostingController<Content>, context: Context) {
        vc.rootView = content
    }
}