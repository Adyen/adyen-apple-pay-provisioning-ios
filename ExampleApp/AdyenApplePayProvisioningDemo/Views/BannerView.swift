//
//  BannerView.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2024 Adyen N.V.
//

import PassKit
import SwiftUI

/// A promotional view encouraging users to add their card to Apple Wallet.
struct BannerView: View {
    /// The possible user interactions within the banner.
    enum Selection {
        case add
        case skip
    }

    /// Callback triggered when the user chooses to either add the card or dismiss the banner.
    let action: (Selection) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image("tap-to-pay-apple")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 160)
                .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(spacing: 8) {
                Text("Make your payments a breeze!")
                    .font(.headline)

                Text("Apple Pay is a safe and fast way to pay in stores and online. Add Apple Pay now.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .multilineTextAlignment(.center)

            Spacer()

            // Uses the UIViewRepresentable wrapper for the native Apple Pay button.
            AddPassButton {
                action(.add)
            }
            .frame(height: 44)

            Button("Skip for now") {
                action(.skip)
            }
            .font(.subheadline)
            .buttonStyle(.plain)
        }
        .padding()
    }
}

#Preview {
    BannerView { _ in }
}
