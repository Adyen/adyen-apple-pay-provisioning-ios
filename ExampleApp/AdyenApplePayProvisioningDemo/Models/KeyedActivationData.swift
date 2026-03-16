//
//  KeyedActivationData.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2026 Adyen N.V.
//

import Foundation

/// Used for caching
struct KeyedActivationData: Codable {
    let paymentInstrumentId: String
    let sdkInput: Data
}
