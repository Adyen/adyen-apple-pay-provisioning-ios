//
//  ViewModel.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2026 Adyen N.V.
//

import AdyenApplePayProvisioning
import Foundation
import PassKit
import SwiftUI
import UIKit

@MainActor
@Observable
final class ViewModel {
    private(set) var appState: AppState
    private(set) var cardState: CardState

    private let networkManager: any NetworkManaging
    private let paymentInstrumentId: String
    private let apiEnvironment: ApiEnvironment
    private let activationDataCacheFactory: ActivationDataCacheFactoryProtocol

    private var provisioningService: ProvisioningService?
    // Never use more than one instance of the WatchAvailability at once
    private let watchAvailability = WatchAvailability()
    private var hasLoadedInitialState = false

    /// Holds a provisioning error to be displayed by the UI.
    var provisioningError: AppError?

    init(
        appState: AppState = .signedOut,
        cardState: CardState = .cannotProvision,
        paymentInstrumentId: String,
        apiEnvironment: ApiEnvironment,
        networkManager: any NetworkManaging,
        activationDataCacheFactory: ActivationDataCacheFactoryProtocol
    ) {
        self.appState = appState
        self.cardState = cardState
        self.paymentInstrumentId = paymentInstrumentId
        self.apiEnvironment = apiEnvironment
        self.networkManager = networkManager
        self.activationDataCacheFactory = activationDataCacheFactory
    }

    // MARK: - App State Management

    func fetchStateIfNeeded() async {
        guard !hasLoadedInitialState else { return }
        hasLoadedInitialState = true
        await fetchState()
    }

    /// Fetches activation data and determines the initial signed-in sub-state.
    func fetchState() async {
        clearProvisioningError()
        provisioningService = nil
        setAppState(.loading)

        let url = ApiEndpoints.provisioning(
            for: apiEnvironment,
            paymentInstrumentId: paymentInstrumentId
        )

        do {
            // Fetch card activation data.
            let activationData: ActivationData = try await networkManager.get(url: url)

            // Cache card activation data so that it can be used from the wallet extension
            let activationDataCache = try activationDataCacheFactory.makeCache()
            activationDataCache.store(
                activationData: KeyedActivationData(
                    paymentInstrumentId: paymentInstrumentId,
                    sdkInput: activationData.sdkInput
                )
            )

            let provisioningService = try ProvisioningService(sdkInput: activationData.sdkInput)
            self.provisioningService = provisioningService

            // Watch is paired and session is activated
            let isWatchActivated = await watchAvailability.activate()
            let cardDetails = provisioningService.canAddCardDetails(isWatchActivated: isWatchActivated)

            if cardDetails.canAddCard {
                cardState = .canProvision(
                    isWatchActivated,
                    cardDetails.canAddToWatch,
                    cardDetails.canAddToPhone
                )

                // Show banner if provisioning is possible after first sign in
                setAppState(.signedIn(.banner))
            } else {
                // The SDK indicates the card is already provisioned
                cardState = .provisioned(isWatchActivated, provisioningService.passURL())
                setAppState(.signedIn(.home))
            }
        } catch {
            // Clear cache if setting up a provisionable card failed
            let activationDataCache = try? activationDataCacheFactory.makeCache()
            activationDataCache?.remove()

            // Show the signed-in home screen with a non-provisionable card state.
            provisioningService = nil
            cardState = .cannotProvision
            setAppState(.signedIn(.home))
        }
    }

    /// Updates the high-level application state.
    func setAppState(_ state: AppState) {
        appState = state
    }

    /// Transitions between sub-states when already signed in.
    func setSignedInState(_ subState: SignedInState) {
        guard case .signedIn = appState else { return }
        appState = .signedIn(subState)
    }

    func signOut() {
        clearProvisioningError()

        let activationDataCache = try? activationDataCacheFactory.makeCache()
        activationDataCache?.remove()

        provisioningService = nil
        hasLoadedInitialState = false
        cardState = .cannotProvision
        appState = .signedOut
    }

    /// Clears any currently displayed provisioning error.
    func clearProvisioningError() {
        provisioningError = nil
    }

    /// Triggers the system Apple Pay provisioning sheet.
    /// - Throws: `AppError` if the service is uninitialized or a view controller is missing.
    func addCardToWallet() throws {
        clearProvisioningError()

        guard let provisioningService else {
            throw AppError(
                code: .provisioningUnavailable,
                description: "Provisioning service is not initialized."
            )
        }

        guard let viewController = UIApplication.shared.topMostViewController else {
            throw AppError(
                code: .provisioningUnavailable,
                description: "Could not find a view controller to present the Apple Pay sheet."
            )
        }

        guard case .canProvision = cardState else {
            throw AppError(
                code: .provisioningUnavailable,
                description: "This card is not currently eligible for provisioning."
            )
        }

        try provisioningService.start(delegate: self, presentingViewController: viewController)
    }
}

// MARK: - ProvisioningServiceDelegate

extension ViewModel: ProvisioningServiceDelegate {
    /// Performs the network handshake required by the SDK to authorize the card with the issuer.
    /// - Returns: The final activation data for the SDK, or `nil` if the request fails.
    func provision(sdkOutput: Data, paymentInstrumentId: String) async -> Data? {
        guard self.paymentInstrumentId == paymentInstrumentId else { return nil }

        let provisionRequest = ProvisioningDataRequest(sdkOutput: sdkOutput)
        let url = ApiEndpoints.provisioning(
            for: apiEnvironment,
            paymentInstrumentId: paymentInstrumentId
        )

        do {
            let provisioningData: ProvisioningData = try await networkManager.post(
                url: url,
                body: provisionRequest
            )
            return provisioningData.sdkInput
        } catch {
            return nil
        }
    }

    /// Callback triggered when the Apple Pay provisioning flow completes.
    func didFinishProvisioning(with pass: PKPaymentPass?, error: (any Error)?) {
        // Handle success.
        if let pass {
            let isWatchAvailable = cardState.hasWatch
            cardState = .provisioned(isWatchAvailable, pass.passURL)

            // Explicitly transition to home only on success.
            setSignedInState(.home)
            return
        }

        // Handle errors/cancellation.
        guard let error else { return }

        if let sdkError = error as? ProvisioningServiceError {
            switch sdkError {
            case .userCancelled:
                // Do nothing; remain on the current screen.
                return

            default:
                provisioningError = AppError(
                    code: .generic,
                    description: "Provisioning failed: \(sdkError.localizedDescription)",
                    underlyingError: sdkError
                )
            }
        } else {
            provisioningError = AppError(
                code: .generic,
                description: error.localizedDescription,
                underlyingError: error
            )
        }
    }
}
