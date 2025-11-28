import SwiftUI
import UIKit

class AccessoryHostingController<Content: View>: UIHostingController<Content> {
    override var canBecomeFirstResponder: Bool { true }
    override var inputAccessoryView: UIView? { view }
}