//
//  HeaderProvider.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2026 Adyen N.V.
//

import Foundation

internal protocol HeaderProviding: Sendable {
    func headers() -> [String: String]
}

/// Production implementation
internal struct APIKeyHeaderProvider: HeaderProviding {
    func headers() -> [String: String] {
        // Do not hardcode your API key :-)
        let apiKey = ""
        return ["x-api-key": apiKey]
    }
}

/// Mock implementation
internal struct EmptyHeaderProvider: HeaderProviding {
    func headers() -> [String: String] {
        [:]
    }
}
