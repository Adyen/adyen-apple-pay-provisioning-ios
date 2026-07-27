//
//  AuthFlowView.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2024 Adyen N.V.
//

import SwiftUI

/// A view that sequences the sign-in and MFA steps and reports the final result.
struct AuthFlowView: View {
    let completion: (Bool) -> Void

    @State private var isMFARequired = false

    var body: some View {
        if isMFARequired {
            MFAView {
                completion(true)
            }
        } else {
            SignInView(completion: { _ in
                isMFARequired = true
            })
        }
    }
}
