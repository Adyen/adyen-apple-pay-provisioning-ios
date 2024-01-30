//
//  AddPassButton.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2024 Adyen N.V.
//

import PassKit
import SwiftUI

struct AddPassButton: UIViewRepresentable {
    typealias UIViewType = PKAddPassButton
    let action: () -> Void

    func makeUIView(context: Context) -> PKAddPassButton {
        let action = UIAction { _ in
            self.action()
        }

        let button = PKAddPassButton(primaryAction: action)
        button.addPassButtonStyle = PKAddPassButtonStyle.blackOutline

        return button
    }

    func updateUIView(_ uiView: PKAddPassButton, context: Context) {}
}

#Preview {
    AddPassButton {}
        .frame(height: 44)
        .padding(10)
}
