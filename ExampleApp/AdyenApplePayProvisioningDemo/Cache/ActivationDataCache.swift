//
//  ActivationDataCache.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2026 Adyen N.V.
//

import Foundation

/// Defines the capabilities for persisting and managing activation data.
internal protocol ActivationDataCaching {
    func store(activationData: KeyedActivationData)
    func remove()
    func retrieve() -> KeyedActivationData?
}

/// A storage wrapper for a single activation data object.
/// This implementation uses a shared App Group suite for persistence.
internal struct ActivationDataCache: ActivationDataCaching {
    private let userDefaults: UserDefaults
    private let appGroupIdentifier = "group.com.adyenApplePayProvisioningDemo.wallet"
    private let activationDataUserDefaultKey = "com.adyenApplePayProvisioningDemo.provisioningActivationDataUserDefaultKey"

    /// Initializes the cache with a shared UserDefaults suite.
    /// - Throws: `AppError` if the App Group suite cannot be initialized.
    internal init() throws {
        guard let userDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            throw AppError(code: .generic, description: "Could not create shared user defaults")
        }

        self.userDefaults = userDefaults
    }

    func store(activationData: KeyedActivationData) {
        do {
            let encoded = try JSONEncoder().encode(activationData)
            userDefaults.set(encoded, forKey: activationDataUserDefaultKey)
        } catch {
            assertionFailure("Failed to encode activation data: \(error)")
        }
    }

    func remove() {
        userDefaults.removeObject(forKey: activationDataUserDefaultKey)
    }

    func retrieve() -> KeyedActivationData? {
        // Retrieve Data and decode back to the object
        guard let data = userDefaults.data(forKey: activationDataUserDefaultKey) else { return nil }
        return try? JSONDecoder().decode(KeyedActivationData.self, from: data)
    }
}

/// A factory protocol for creating instances of `ActivationDataCaching`.
internal protocol ActivationDataCacheFactoryProtocol {
    /// - Throws: `AppError`
    func makeCache() throws -> ActivationDataCaching
}

internal struct ActivationDataCacheFactory: ActivationDataCacheFactoryProtocol {
    /// Creates a new instance of the activation data cache.
    /// - Throws: `AppError`
    func makeCache() throws -> ActivationDataCaching {
        try ActivationDataCache()
    }
}
