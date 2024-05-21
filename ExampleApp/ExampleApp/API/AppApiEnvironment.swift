//
//  AppApiEnvironment.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2024 Adyen N.V.
//

import AdyenNetworking
import Foundation

struct AppApiEnvironment: AnyAPIEnvironment {
    var baseURL = URL(string: "https://yourbackendservice.com/")!
}
