//
//  ActivationData.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2026 Adyen N.V.
//

import Foundation

/// Data received from the Adyen backend required to initialize the Apple Pay provisioning process.
internal struct ActivationData: Decodable {

    /// The base64-encoded or raw data blob provided to the SDK hand-off.
    let sdkInput: Data
}
