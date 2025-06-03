//
//  KeyboardAccessory.swift
//  SimplePhotoEditor
//
//  Created by ikorobov on 19. 5. 2025..
//


import SwiftUI
import UIKit

/// SwiftUI‐обёртка для InputAccessory
struct KeyboardAccessory<Content: View>: UIViewControllerRepresentable {
    let content: Content

    func makeUIViewController(context: Context) -> AccessoryHostingController<Content> {
        AccessoryHostingController(rootView: content)
    }

    func updateUIViewController(_ vc: AccessoryHostingController<Content>, context: Context) {
        vc.rootView = content
    }
}