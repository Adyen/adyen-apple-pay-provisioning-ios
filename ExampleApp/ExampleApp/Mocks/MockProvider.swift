//
//  MockProvider.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2024 Adyen N.V.
//

import Foundation

enum MockProvider {
    private static let cardActivationResponse = #"{"sdkInput":"eyJwYXltZW50SW5zdHJ1bWVudElkIjoiUEFZTUVOVF9JTlNUUlVNRU5UX0lEIiwiY2FyZGhvbGRlck5hbWUiOiJKb2hubnkgQXBwbGVzZWVkIiwiYnJhbmQiOiJ2aXNhIiwibGFzdEZvdXIiOiI4OTUyIiwic3VwcG9ydGVkV2FsbGV0cyI6WyJnb29nbGVQYXkiLCJhcHBsZVBheSJdfQ=="}"#

    static func data(for request: URLRequest) -> Data {
        // Currently only mocks activation endpoint
        switch request.url?.lastPathComponent {
        case "networkTokenActivationData":
            Data(cardActivationResponse.utf8)
        default:
            Data()
        }
    }
}
