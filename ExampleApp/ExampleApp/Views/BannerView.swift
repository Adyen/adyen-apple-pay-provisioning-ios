//
//  BannerView.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2024 Adyen N.V.
//

import PassKit
import SwiftUI

struct BannerView: View {
    enum Result {
        case add
        case skip
    }

    let action: (Result) -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image("tap-to-pay-apple")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 160)
                .cornerRadius(10)

            Text("Make your payments a breeze!")
                .font(.headline)
                .multilineTextAlignment(.center)

            Text("Apple Pay is a safe and fast way to pay in stores and online. Add Apple Pay now.")
                .font(.callout)
                .multilineTextAlignment(.center)

            Spacer()

            AddPassToWalletButton {
                action(.add)
            }
            .frame(height: 44)

            Button {
                action(.skip)
            } label: {
                Text("Skip now")
            }
        }
        .padding()
    }
}

#Preview {
    BannerView { _ in }
}
