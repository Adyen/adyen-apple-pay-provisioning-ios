//
//  ApiEndpoints.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2026 Adyen N.V.
//

import Foundation

/// A collection of static factory methods for constructing Adyen API URLs.
internal enum ApiEndpoints {

    /// Constructs the URL for retrieving and submitting network token activation data.
    /// - Parameters:
    ///   - environment: The target `ApiEnvironment` (e.g., .test or .live).
    ///   - paymentInstrumentId: The unique identifier for the payment instrument being provisioned.
    /// - Returns: A complete URL for the provisioning endpoint.
    static func provisioning(for environment: ApiEnvironment, paymentInstrumentId: String) -> URL {
        environment.baseURL
            .appending(path: "bcl/v2/paymentInstruments")
            .appending(path: paymentInstrumentId)
            .appending(path: "networkTokenActivationData")
    }
}
