//
//  MockMode.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2026 Adyen N.V.
//

import Foundation

internal struct MockMode {
    private let userDefaults: UserDefaults?
    private let appGroupIdentifier = "group.com.adyenApplePayProvisioningDemo.wallet"
    private let mockModeUserDefaultKey = "com.adyenApplePayProvisioningDemo.mockModeFlag"

    private let defaultMode = true // On by default

    internal init() {
        self.userDefaults = UserDefaults(suiteName: appGroupIdentifier)
    }

    @discardableResult
    func set(_ value: Bool) -> Bool {
        guard let userDefaults else {
            return defaultMode
        }

        userDefaults.set(value, forKey: mockModeUserDefaultKey)
        return value
    }

    func value() -> Bool {
        guard let userDefaults else {
            return defaultMode
        }

        if userDefaults.object(forKey: mockModeUserDefaultKey) == nil {
            return defaultMode
        }

        return userDefaults.bool(forKey: mockModeUserDefaultKey)
    }
}
