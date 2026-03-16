//
//  ApiEnvironment.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2026 Adyen N.V.
//

import Foundation

/// Defines the backend environment used for Adyen Balance Platform API requests.
internal enum ApiEnvironment {

    /// Use for development and integration testing.
    case test

    /// Use for production traffic.
    case live

    /// The base URL for the Adyen Balance Platform API corresponding to the environment.
    var baseURL: URL {
        switch self {
        case .live:
            // Production environment for live transactions.
            URL(string: "https://balanceplatform-api-live.adyen.com/")!
        case .test:
            // Sandbox environment for testing and validation.
            URL(string: "https://balanceplatform-api-test.adyen.com/")!
        }
    }
}
