//
//  AppError.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2024 Adyen N.V.
//

import Foundation

enum AppError: Error, LocalizedError {
    case generic

    var errorDescription: String? {
        switch self {
        case .generic:
            "Something went wrong"
        }
    }
}
