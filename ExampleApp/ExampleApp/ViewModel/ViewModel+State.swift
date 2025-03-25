//
//  ViewModel+State.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2024 Adyen N.V.
//

import Foundation

extension ViewModel {
    enum AppState {
        case signedOut
        case loading
        case banner
        case signedIn(ViewModel)
    }

    enum CardState: Equatable {
        typealias IsWatchAvailable = Bool
        typealias CanAddToWatch = Bool
        typealias CanAddToPhone = Bool
        typealias PassUrl = URL

        case canProvision(IsWatchAvailable, CanAddToWatch, CanAddToPhone)
        case provisioned(IsWatchAvailable, PassUrl?)
        case cannotProvision

        var text: String {
            switch self {
            case let .canProvision(isWatchAvailable, canAddToWatch, canAddToPhone):
                if canAddToPhone, canAddToWatch {
                    return "Card can be added to your phone and watch"
                } else if !canAddToPhone, canAddToWatch {
                    return "Card is available on phone but can also be added to your watch"
                } else if isWatchAvailable, !canAddToWatch {
                    return "Card is available on your watch but can also be added to your phone"
                } else {
                    return "Card can be added to your phone"
                }
            case let .provisioned(isWatchAvailable, _):
                return isWatchAvailable ? "Card is available on your phone and watch" : "Card is available on your phone"
            case .cannotProvision:
                return "Card cannot be added"
            }
        }
    }
}
