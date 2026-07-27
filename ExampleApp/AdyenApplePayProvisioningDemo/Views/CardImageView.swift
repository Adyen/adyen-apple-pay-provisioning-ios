//
//  CardImageView.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2024 Adyen N.V.
//

import SwiftUI

/// A shared card visual used across the app, showing the card art with the masked card number.
struct CardImageView: View {
    var body: some View {
        Image("visa_card")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("John Doe")
                        .font(.system(size: 12, weight: .regular, design: .monospaced))
                        .foregroundStyle(.black)

                    Text("**** **** **** 2132")
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(.black)
                }
                .padding(.leading, 12)
                .padding(.bottom, 12)
            }
    }
}

#Preview {
    CardImageView()
        .padding()
}
