//
//  AdyenApplePayProvisioningDemoApp.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2026 Adyen N.V.
//

import SwiftUI

/// The main entry point for the Adyen Apple Pay Provisioning demo application.
@main
struct AdyenApplePayProvisioningDemoApp: App {
    static let isMockMode = MockMode().set(true)

    @State private var viewModel: ViewModel = {
        let session: URLSession = isMockMode ? URLSession(configuration: .mock) : .shared

        let headerProvider: any HeaderProviding = isMockMode
            ? EmptyHeaderProvider()
            : APIKeyHeaderProvider()

        return ViewModel(
            // For non-mock mode use a real PI
            paymentInstrumentId: "PAYMENT_INSTRUMENT_ID",
            apiEnvironment: .test,
            networkManager: NetworkManager(session: session, headerProvider: headerProvider),
            activationDataCacheFactory: ActivationDataCacheFactory()
        )
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
    }
}
