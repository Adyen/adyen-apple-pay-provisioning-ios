//
//  CardView.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2026 Adyen N.V.
//

import PassKit
import SwiftUI

/// A view that displays a digital representation of a payment card and its provisioning status.
struct CardView: View {
    /// The view model containing the card's current state and provisioning logic.
    let viewModel: ViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            cardImage

            statusBadge

            Spacer()

            provisioningControls(for: viewModel.cardState)
        }
        .padding(10)
        // Observe the shared provisioning error state from the ViewModel.
        // This handles both local launch errors and SDK delegate errors.
        .alert(item: Bindable(viewModel).provisioningError) { error in
            Alert(
                title: Text("Wallet Error"),
                message: Text(error.localizedDescription),
                dismissButton: .default(Text("OK")) {
                    viewModel.clearProvisioningError()
                }
            )
        }
    }

    // MARK: - Subviews

    /// The visual representation of the physical or digital card.
    private var cardImage: some View {
        Image("visa_card")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }

    /// A badge indicating that the card is active in the system.
    private var statusBadge: some View {
        HStack {
            Spacer()
            Text("Active")
                .font(.caption.bold())
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(.green, in: Capsule())
            Spacer()
        }
    }

    /// Generates the appropriate UI controls based on the card's provisioning state.
    private func provisioningControls(for state: ViewModel.CardState) -> some View {
        VStack(spacing: 12) {
            switch state {
            case .canProvision:
                // Standard Apple-branded button for provisioning.
                AddPassButton {
                    provisionCard()
                }
                .frame(height: 44)

            case let .provisioned(_, passURL):
                if let url = passURL {
                    Button("Open Wallet") {
                        UIApplication.shared.open(url)
                    }
                    .buttonStyle(.borderedProminent)
                }

            case .cannotProvision:
                EmptyView()
            }

            Text(state.text)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(10)
    }

    // MARK: - Private Methods

    private func provisionCard() {
        do {
            try viewModel.addCardToWallet()
        } catch {
            // Map immediate startup errors to the shared ViewModel error property.
            viewModel.provisioningError = AppError(
                code: .provisioningUnavailable,
                description: error.localizedDescription,
                underlyingError: error
            )
        }
    }
}

#Preview {
    CardView(
        viewModel: ViewModel(
            paymentInstrumentId: "PREVIEW_ID",
            apiEnvironment: .test,
            networkManager: NetworkManager(
                session: .shared,
                headerProvider: EmptyHeaderProvider()
            ),
            activationDataCacheFactory: ActivationDataCacheFactory()
        )
    )
}
