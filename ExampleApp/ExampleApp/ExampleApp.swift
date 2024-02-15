//
//  ExampleApp.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2024 Adyen N.V.
//

import AdyenNetworking
import SwiftUI

@main
struct ExampleApp: App {
    @State var viewModel = ViewModel(
        // PAYMENT_INSTRUMENT_ID will be used to fetch activation data
        paymentInstrumentId: "PAYMENT_INSTRUMENT_ID",
        apiClient: AppAPIClient(
            // Pass nil or remove this parameter to make real network calls
            configuration: URLSessionConfiguration.mock
        )
    )

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
        }
    }
}
