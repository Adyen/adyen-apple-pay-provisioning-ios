//
//  AppApiContext.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2024 Adyen N.V.
//

import AdyenNetworking
import Foundation

struct AppApiContext: AnyAPIContext {
    let environment: AnyAPIEnvironment
    let headers: [String: String]
    let queryParameters: [URLQueryItem] = []

    init() {
        // You can add your Authorization header here
        self.headers = [
            "Content-Type": "application/json"
        ]

        self.environment = AppApiEnvironment()
    }
}
