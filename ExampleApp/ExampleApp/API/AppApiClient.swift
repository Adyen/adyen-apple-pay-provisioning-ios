//
//  AppApiClient.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2024 Adyen N.V.
//

import AdyenNetworking
import Foundation

class AppAPIClient: AsyncAPIClientProtocol {
    let apiClient: APIClient

    init(apiContext: AnyAPIContext = AppApiContext(), configuration: URLSessionConfiguration? = nil) {
        self.apiClient = APIClient(apiContext: apiContext, configuration: configuration)
    }

    func perform<R>(_ request: R) async throws -> AdyenNetworking.HTTPResponse<R.ResponseType> where R: AdyenNetworking.Request {
        try await apiClient.perform(request)
    }
}
