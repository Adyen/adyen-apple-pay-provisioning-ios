//
//  URLSessionConfiguration+Mock.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2024 Adyen N.V.
//

import Foundation

extension URLSessionConfiguration {
    static var mock = {
        var config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return config
    }()
}
