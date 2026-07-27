//
//  SessionStore.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2024 Adyen N.V.
//

import Foundation

/// Persists the user's sign-in state in the shared App Group so both the demo app
/// and the wallet non-UI extension can read it.
internal struct SessionStore {
    private let userDefaults: UserDefaults?
    private let appGroupIdentifier = "group.com.adyenApplePayProvisioningDemo.wallet"
    private let key = "com.adyenApplePayProvisioningDemo.isSignedIn"

    internal init() {
        self.userDefaults = UserDefaults(suiteName: appGroupIdentifier)
    }

    var isSignedIn: Bool {
        userDefaults?.bool(forKey: key) ?? false
    }

    func setSignedIn(_ value: Bool) {
        userDefaults?.set(value, forKey: key)
    }
}
