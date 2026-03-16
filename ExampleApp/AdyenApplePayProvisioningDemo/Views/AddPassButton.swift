//
//  AddPassButton.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2024 Adyen N.V.
//

import PassKit
import SwiftUI

/// A SwiftUI wrapper for the `PKAddPassButton` provided by the PassKit framework.
struct AddPassButton: UIViewRepresentable {
    typealias UIViewType = PKAddPassButton

    /// The closure to execute when the button is tapped.
    let action: () -> Void

    func makeUIView(context: Context) -> PKAddPassButton {
        let uiAction = UIAction { _ in
            action()
        }

        // Initialize the standard Apple "Add to Apple Wallet" button.
        let button = PKAddPassButton(primaryAction: uiAction)
        button.addPassButtonStyle = .blackOutline
        return button
    }

    func updateUIView(_ uiView: PKAddPassButton, context: Context) {
        // No dynamic updates required for the static add-pass button.
    }
}

#Preview {
    AddPassButton {
        print("Button tapped")
    }
    .frame(height: 44)
    .padding(10)
}
