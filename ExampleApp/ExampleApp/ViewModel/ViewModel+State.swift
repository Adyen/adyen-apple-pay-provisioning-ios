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
        enum IconState {
            case deviceAvailable, deviceUnavailable, none
        }

        typealias Phone = IconState
        typealias Watch = IconState

        case canAdd(Phone, Watch)
        case added(Watch)
        case unknown
    }
}
