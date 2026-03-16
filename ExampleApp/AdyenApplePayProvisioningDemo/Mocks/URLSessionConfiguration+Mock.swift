//
//  URLSessionConfiguration+Mock.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2024 Adyen N.V.
//

import Foundation

extension URLSessionConfiguration {
    static let mock = {
        var config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return config
    }()
}
