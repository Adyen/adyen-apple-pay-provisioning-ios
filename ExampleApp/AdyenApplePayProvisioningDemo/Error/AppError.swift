//
//  AppError.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2026 Adyen N.V.
//

import AdyenApplePayProvisioning
import Foundation
import PassKit
import SwiftUI
import UIKit

// MARK: - AppError

/// A unified error type for the application, conforming to `LocalizedError` for user-facing descriptions.
public struct AppError: Error, LocalizedError, Identifiable {
    /// A stable identifier for programmatic error handling.
    public struct Code: Hashable, RawRepresentable, Sendable {
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }

        public static let generic = Code(rawValue: "generic")
        public static let networkingError = Code(rawValue: "networking_error")
        public static let provisioningUnavailable = Code(rawValue: "provisioning_unavailable")
    }

    /// The category identifier for this error.
    public let code: Code

    /// A developer-provided or system-generated explanation.
    private let message: String?

    /// The original error that triggered this instance.
    /// Kept for diagnostics and logging on the main actor.
    public let underlyingError: (any Error)?

    public init(
        code: Code,
        description: String? = nil,
        underlyingError: (any Error)? = nil
    ) {
        self.code = code
        self.message = description
        self.underlyingError = underlyingError
    }

    /// A localized message suitable for display to the user.
    public var errorDescription: String? {
        if let message {
            return message
        }

        if let underlyingError {
            return underlyingError.localizedDescription
        }

        return "Something went wrong."
    }

    public var id: String {
        [
            code.rawValue,
            message ?? "",
            underlyingError?.localizedDescription ?? ""
        ]
        .joined(separator: "|")
    }
}

// MARK: - Standard Errors

extension AppError {
    /// A fallback error for unspecified failure scenarios.
    public static var generic: AppError {
        AppError(code: .generic)
    }

    /// Wraps a networking failure with an optional underlying error.
    public static func networkingError(_ error: (any Error)? = nil) -> AppError {
        AppError(
            code: .networkingError,
            description: "The request failed.",
            underlyingError: error
        )
    }

    /// Indicates that the provisioning flow could not be started.
    public static func provisioningUnavailable(_ error: (any Error)? = nil) -> AppError {
        AppError(
            code: .provisioningUnavailable,
            description: "Apple Pay provisioning is currently unavailable.",
            underlyingError: error
        )
    }
}
