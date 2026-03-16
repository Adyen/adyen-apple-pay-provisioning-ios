//
//  ProvisioningData.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2026 Adyen N.V.
//

import Foundation

/// Data returned from the backend after a successful provisioning request.
internal struct ProvisioningData: Decodable {

    /// The final activation payload required by the SDK to complete the process.
    let sdkInput: Data
}
