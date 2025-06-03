//
//  AccessoryHostingController.swift
//  SimplePhotoEditor
//
//  Created by ikorobov on 19. 5. 2025..
//


import SwiftUI
import UIKit

/// Контроллер, который выставляет SwiftUI‐вью как inputAccessoryView
class AccessoryHostingController<Content: View>: UIHostingController<Content> {
    override var canBecomeFirstResponder: Bool { true }
    override var inputAccessoryView: UIView? { view }
}