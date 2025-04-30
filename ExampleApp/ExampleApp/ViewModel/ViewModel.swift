//
//  ViewModel.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2024 Adyen N.V.
//

import AdyenApplePayProvisioning
import AdyenNetworking
import PassKit
import SwiftUI
import UIKit

final class ViewModel: ObservableObject {
    @Published private(set) var appState: AppState
    @Published private(set) var cardState: CardState

    private let apiClient: AsyncAPIClientProtocol
    private let paymentInstrumentId: String
    private var watchAvailability = WatchAvailability()

    private var provisioningService: ProvisioningService?

    init(appState: AppState = .signedOut,
         cardState: CardState = .cannotProvision,
         paymentInstrumentId: String,
         apiClient: AsyncAPIClientProtocol) {
        self.appState = appState
        self.cardState = cardState
        self.paymentInstrumentId = paymentInstrumentId
        self.apiClient = apiClient
    }

    @MainActor
    func fetchState() async throws {
        // Request SDK activation data
        setAppState(.loading)
        let tokenActivationRequest = TokenActivationRequest(paymentInstrumentId: paymentInstrumentId)
        let tokenActivationResponse = try await apiClient.perform(tokenActivationRequest).responseBody

        // Provisioning service is initialized with activation data received from the backend
        let provisioningService = try ProvisioningService(sdkInput: tokenActivationResponse.sdkInput)
        self.provisioningService = provisioningService
        let isWatchActivated = await watchAvailability.activate()
        let cardDetails = provisioningService.canAddCardDetails(isWatchActivated: isWatchActivated)

        // Checking if the card can be added to the phone or the watch.
        if cardDetails.canAddCard {
            cardState = .canProvision(isWatchActivated, cardDetails.canAddToWatch, cardDetails.canAddToPhone)
            setAppState(.banner)
        } else {
            cardState = .provisioned(isWatchActivated, provisioningService.passURL())
            setAppState(.signedIn(self))
        }
    }

    /// Setting state will rerender the view
    func setAppState(_ state: AppState) {
        appState = state
    }

    /// Starts card provisioning flow
    func addCardToWallet() throws {
        guard
            let provisioningService,
            let viewController = UIApplication.shared.rootViewController
        else {
            throw AppError.generic
        }

        switch cardState {
        case .canProvision:
            try provisioningService.start(delegate: self, presentingViewController: viewController)
        default:
            throw AppError.generic
        }
    }
}

extension ViewModel: ProvisioningServiceDelegate {
    func provision(sdkOutput: Data, paymentInstrumentId: String) async -> Data? {
        guard self.paymentInstrumentId == paymentInstrumentId else {
            return nil
        }

        let provisionRequest = ProvisionCardRequest(
            paymentInstrumentId: paymentInstrumentId,
            sdkOutput: sdkOutput
        )

        do {
            // Provisioning service produces data which needs to be passed to the backend
            let result = try await apiClient.perform(provisionRequest)
            // Pass sdkInput back to the Provisioning service for final step of provisioning
            return result.responseBody.sdkInput
        } catch {
            return nil
        }
    }

    func didFinishProvisioning(with pass: PKPaymentPass?, error: Error?) {
        // Display completion info when this is called
    }
}
