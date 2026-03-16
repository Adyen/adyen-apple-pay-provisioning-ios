//
//  MockProvider.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2024 Adyen N.V.
//

import Foundation

enum MockProvider {
    private static let cardActivationResponse = #"{"sdkInput":"eyJwYXltZW50SW5zdHJ1bWVudElkIjoiUEk1MlZMMzIyMzIyN0w1TU44VE4zRzUzRSIsImNhcmRob2xkZXJOYW1lIjoiSm9obm55IEFwcGxlc2VlZCIsImJyYW5kIjoidmlzYSIsImxhc3RGb3VyIjoiODk1MiIsInN1cHBvcnRlZFdhbGxldHMiOlsiZ29vZ2xlUGF5IiwiYXBwbGVQYXkiXX0KCgo="}"#

    static func data(for request: URLRequest) -> Data {
        // Currently we're only mocking the GET activation data endpoint
        switch request.url?.lastPathComponent {
        case "networkTokenActivationData":
            if request.httpMethod == "GET" {
                return Data(cardActivationResponse.utf8)
            } else {
                return Data()
            }
        default:
            return Data()
        }
    }
}
