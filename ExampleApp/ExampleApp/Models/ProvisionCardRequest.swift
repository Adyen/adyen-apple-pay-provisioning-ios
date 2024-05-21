//
//  ProvisionCardRequest.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2024 Adyen N.V.
//

import AdyenNetworking
import Foundation

struct ProvisionCardRequest: Request {
    typealias ResponseType = ProvisionCardResponse
    typealias ErrorResponseType = EmptyErrorResponse

    let paymentInstrumentId: String
    let sdkOutput: Data
    var path: String { "paymentInstruments/\(paymentInstrumentId)/networkTokenActivationData" }
    var counter: UInt = 0
    let headers: [String: String] = [:]
    let queryParameters: [URLQueryItem] = []
    let method: AdyenNetworking.HTTPMethod = .post

    enum CodingKeys: String, CodingKey {
        case sdkOutput
    }
}
