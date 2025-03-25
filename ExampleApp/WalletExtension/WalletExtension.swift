//
//  WalletExtension.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2025 Adyen N.V.
//

import AdyenApplePayExtensionProvisioning
import PassKit

class WalletExtension: PKIssuerProvisioningExtensionHandler, ExtensionProvisioningServiceDelegate {

    // This task needs to complete in under 100ms
    // so there is no time for a network call.
    // Use activation data which you cached earlier in the app
    override open func status() async -> PKIssuerProvisioningExtensionStatus {
        guard let service = await provisioningService(retrieveNewData: false) else {
            return ExtensionProvisioningService.entriesUnavailableExtensionStatus
        }

        return service.extensionStatus(requiresAuthentication: true)
    }

    // Checks existing cards on the iPhone wallet
    override open func passEntries() async -> [PKIssuerProvisioningExtensionPassEntry] {
        guard let service = await provisioningService(retrieveNewData: true) else {
            return []
        }

        return service.passEntries(withDelegate: self)
    }

    // Checks existing cards on the Apple Watch wallet
    override open func remotePassEntries() async -> [PKIssuerProvisioningExtensionPassEntry] {
        guard let service = await provisioningService(retrieveNewData: true) else {
            return []
        }

        return service.remotePassEntries(withDelegate: self)
    }

    override open func generateAddPaymentPassRequestForPassEntryWithIdentifier(
        _ identifier: String,
        configuration: PKAddPaymentPassRequestConfiguration,
        certificateChain certificates: [Data],
        nonce: Data, nonceSignature: Data
    ) async -> PKAddPaymentPassRequest? {
        // Make sure here you use fresh activation data
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

    private func provisioningService(retrieveNewData: Bool) async -> ExtensionProvisioningService? {
        guard retrieveNewData else {
            // Get cached activation data when there is no time for a network call
            let cachedActivationData = [Data()]
            // Pass the data to the SDK
            return try? ExtensionProvisioningService(sdkInputs: cachedActivationData)
        }

        // Fetch latest activation data from the network and update your cache
        let freshActivationData = [Data()]
        // Cache the data ...
        // Pass the data to the SDK
        return try? ExtensionProvisioningService(sdkInputs: freshActivationData)
    }

    // MARK: - ExtensionProvisioningServiceDelegate

    func provision(paymentInstrumentId: String, sdkOutput: Data) async -> Data? {
        let provisionRequest = ProvisionCardRequest(
            paymentInstrumentId: paymentInstrumentId,
            sdkOutput: sdkOutput
        )

        let apiClient = AppAPIClient()
        let result = try? await apiClient.perform(provisionRequest)
        let sdkInput = result?.responseBody.sdkInput

        return sdkInput
    }

    func cardArt(paymentInstrumentId _: String) -> CGImage {
        UIImage(named: "visa_card")!.cgImage!
    }
}
