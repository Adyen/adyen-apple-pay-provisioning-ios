//
//  TokenActivationRequest.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2024 Adyen N.V.
//

import AdyenNetworking
import Foundation

struct TokenActivationRequest: Request {
    typealias ResponseType = TokenActivationResponse
    typealias ErrorResponseType = EmptyErrorResponse

    let paymentInstrumentId: String
    var path: String { "paymentInstruments/\(paymentInstrumentId)/networkTokenActivationData" }
    var counter: UInt = 0
    let headers: [String: String] = [:]
    let queryParameters: [URLQueryItem] = []
    let method: AdyenNetworking.HTTPMethod = .get

    func encode(to encoder: Encoder) throws {}
}
