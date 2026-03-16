//
//  MockURLProtocol+HandleRequest.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2024 Adyen N.V.
//

import Foundation

extension MockURLProtocol {
    func handle(_ request: URLRequest) throws -> (HTTPURLResponse, Data) {
        (HTTPURLResponse(), MockProvider.data(for: request))
    }
}
