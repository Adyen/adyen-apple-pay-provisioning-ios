//
//  AdyenApplePayProvisioningDemoWalletNonUIExtension.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2026 Adyen N.V.
//

import AdyenApplePayExtensionProvisioning
import PassKit

class AdyenApplePayProvisioningDemoWalletNonUIExtension: PKIssuerProvisioningExtensionHandler, ExtensionProvisioningServiceDelegate {

    /// Mock mode is configured in the main application.
    lazy var isMockMode = MockMode().value()
    lazy var urlSession = isMockMode ? URLSession(configuration: .mock) : .shared
    lazy var headerProvider: HeaderProviding = isMockMode ? EmptyHeaderProvider() : APIKeyHeaderProvider()
    lazy var networkManager = NetworkManager(session: urlSession, headerProvider: headerProvider)
    let apiEnvironment = ApiEnvironment.test

    /// Returns the extension status.
    /// This task must complete in under 100ms; use cached activation data as there is no time for network calls.
    /// This method is responsible for displaying the app icon in the "From Apps on Your iPhone" section.
    override open func status() async -> PKIssuerProvisioningExtensionStatus {
        guard let provisioningService = await provisioningService(retrieveNewData: false) else {
            return ExtensionProvisioningService.entriesUnavailableExtensionStatus
        }

        return provisioningService.extensionStatus(requiresAuthentication: true)
    }

    /// Retrieves available pass entries for the local iPhone wallet.
    override open func passEntries() async -> [PKIssuerProvisioningExtensionPassEntry] {
        guard let provisioningService = await provisioningService(retrieveNewData: true) else {
            return []
        }

        return provisioningService.passEntries(withDelegate: self)
    }

    /// Retrieves available pass entries for the Apple Watch wallet.
    override open func remotePassEntries() async -> [PKIssuerProvisioningExtensionPassEntry] {
        guard let provisioningService = await provisioningService(retrieveNewData: true) else {
            return []
        }

        return provisioningService.remotePassEntries(withDelegate: self)
    }

    /// Generates a request to add a payment pass for a specific identifier.
    /// Ensures fresh activation data is used for the request.
    override open func generateAddPaymentPassRequestForPassEntryWithIdentifier(
        _ identifier: String,
        configuration: PKAddPaymentPassRequestConfiguration,
        certificateChain certificates: [Data],
        nonce: Data,
        nonceSignature: Data
    ) async -> PKAddPaymentPassRequest? {
        guard let provisioningService = await provisioningService(retrieveNewData: true) else {
            return nil
        }

        return try? await provisioningService.generateAddPaymentPassRequestForPassEntryWithIdentifier(
            identifier,
            configuration: configuration,
            certificateChain: certificates,
            nonce: nonce,
            nonceSignature: nonceSignature,
            delegate: self
        )
    }

    /// Initializes the provisioning service, optionally fetching fresh data from the network.
    private func provisioningService(retrieveNewData: Bool) async -> ExtensionProvisioningService? {
        guard let cachedActivationData = try? ActivationDataCache().retrieve() else {
            return nil
        }

        guard retrieveNewData else {
            // Use cached data for time-sensitive calls (e.g., status()).
            return try? ExtensionProvisioningService(sdkInput: cachedActivationData.sdkInput)
        }

        // Fetch and cache the latest activation data for pass entry requests.
        guard let freshActivationData: ActivationData = try? await networkManager.get(
            url: ApiEndpoints.provisioning(for: apiEnvironment, paymentInstrumentId: cachedActivationData.paymentInstrumentId)
        ) else {
            return nil
        }

        try? ActivationDataCache().store(
            activationData: KeyedActivationData(
                paymentInstrumentId: cachedActivationData.paymentInstrumentId,
                sdkInput: freshActivationData.sdkInput
            )
        )

        return try? ExtensionProvisioningService(sdkInput: freshActivationData.sdkInput)
    }

    // MARK: - ExtensionProvisioningServiceDelegate

    /// Handles the provisioning network request.
    func provision(paymentInstrumentId: String, sdkOutput: Data) async -> Data? {
        let provisionRequest = ProvisioningDataRequest(sdkOutput: sdkOutput)

        let data: ProvisioningData? = try? await networkManager.post(
            url: ApiEndpoints.provisioning(for: apiEnvironment, paymentInstrumentId: paymentInstrumentId),
            body: provisionRequest
        )

        return data?.sdkInput
    }

    /// Provides the card art image for a given payment instrument.
    func cardArt(paymentInstrumentId _: String) -> CGImage {
        guard let image = UIImage(named: "visa_card")?.cgImage else {
            preconditionFailure("Critical Asset Missing: 'visa_card' must be in the asset catalog.")
        }

        return image
    }
}
