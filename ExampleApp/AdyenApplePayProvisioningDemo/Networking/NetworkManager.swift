//
//  NetworkManager.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2026 Adyen N.V.
//

import Foundation

/// A protocol defining the core networking capabilities for provisioning.
internal protocol NetworkManaging: Sendable {
    /// Performs a GET request.
    /// - Throws: `AppError`
    func get<T: Decodable & Sendable>(url: URL) async throws(AppError) -> T

    /// Performs a POST request.
    /// - Throws: `AppError`
    func post<T: Decodable & Sendable>(url: URL, body: some Encodable & Sendable) async throws(AppError) -> T
}

/// A lightweight wrapper around `URLSession` to handle JSON-based API requests.
internal struct NetworkManager: NetworkManaging {
    private let session: URLSession
    private let headerProvider: any HeaderProviding

    internal init(session: URLSession = .shared, headerProvider: any HeaderProviding) {
        self.session = session
        self.headerProvider = headerProvider
    }

    /// Injects provider-supplied headers into the request.
    private func applyHeaders(to request: inout URLRequest) {
        let headers = headerProvider.headers()
        for (field, value) in headers {
            request.setValue(value, forHTTPHeaderField: field)
        }
    }

    /// Performs a GET request to the specified URL.
    /// - Parameter url: The destination endpoint.
    /// - Returns: A decoded model of type `T`.
    /// - Throws: `AppError` if the request fails or decoding fails.
    internal func get<T: Decodable & Sendable>(url: URL) async throws(AppError) -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        applyHeaders(to: &request)
        return try await perform(request: request)
    }

    /// Performs a POST request with a JSON-encoded body.
    /// - Parameters:
    ///   - url: The destination endpoint.
    ///   - body: The encodable object to send.
    /// - Returns: A decoded model of type `T`.
    /// - Throws: `AppError` if encoding, the request, or decoding fails.
    internal func post<T: Decodable & Sendable>(url: URL, body: some Encodable & Sendable) async throws(AppError) -> T {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        applyHeaders(to: &request)

        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            throw AppError(code: .networkingError, description: "Could not encode the POST body.")
        }

        return try await perform(request: request)
    }

    // MARK: - Private Helpers

    /// Executes the network request and maps errors to the internal domain.
    /// - Parameter request: The prepared `URLRequest`.
    /// - Throws: `AppError`
    private nonisolated func perform<T: Decodable & Sendable>(request: URLRequest) async throws(AppError) -> T {
        do {
            let (data, response) = try await session.data(for: request)
            return try handleResponse(data: data, response: response)
        } catch let appError as AppError {
            throw appError
        } catch {
            throw AppError(code: .networkingError, description: "The request failed.", underlyingError: error)
        }
    }

    /// Validates the HTTP status code and decodes the JSON payload.
    /// - Parameters:
    ///   - data: The raw response data.
    ///   - response: The URL response metadata.
    /// - Throws: `AppError`
    private nonisolated func handleResponse<T: Decodable & Sendable>(data: Data, response: URLResponse) throws(AppError) -> T {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError(code: .networkingError, description: "No response received from the server.")
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw AppError(code: .networkingError, description: "Failed request. Status code: \(httpResponse.statusCode)")
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw AppError(code: .networkingError, description: "Failed to decode the response payload.", underlyingError: error)
        }
    }
}
