//
//  CardView.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2024 Adyen N.V.
//

import PassKit
import SwiftUI

struct CardView: View {
    @ObservedObject var viewModel: ViewModel
    @State var isShowingError = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Image("visa_card")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .border(.gray)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.gray), lineWidth: 1)
                )

            HStack {
                Spacer()
                Text("Active")
                    .frame(width: 100, height: 32)
                    .font(.caption)
                    .foregroundColor(.white)
                    .background(.green)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(.green), lineWidth: 1)
                    )
                Spacer()
            }

            Spacer()

            view(for: viewModel.cardState)
        }
        .padding(10)
        .alert(isPresented: $isShowingError) {
            Alert(title: Text("Could not add a card to the Wallet"))
        }
    }

    @ViewBuilder
    func view(for state: ViewModel.CardState) -> some View {
        VStack(spacing: 10) {
            if case .canProvision = state {
                AddPassToWalletButton {
                    do {
                        try viewModel.addCardToWallet()
                    } catch {
                        isShowingError = true
                    }
                }
                .frame(height: 44)
            }

            if case let .provisioned(_, passUrl) = state, let url = passUrl {
                Button("Open Wallet") {
                    UIApplication.shared.open(url)
                }
                .frame(width: 160)
                .foregroundColor(.white)
            }

            Text(state.text)
                .multilineTextAlignment(.center)
        }
        .padding(10)
    }
}

#Preview {
    CardView(
        viewModel: ViewModel(
            paymentInstrumentId: "",
            apiClient: AppAPIClient(configuration: URLSessionConfiguration.mock)
        )
    )
}
