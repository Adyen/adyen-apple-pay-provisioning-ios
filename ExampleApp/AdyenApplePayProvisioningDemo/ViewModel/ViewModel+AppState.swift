//
//  ViewModel+AppState.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2026 Adyen N.V.
//

import Foundation
import UIKit

extension ViewModel {
    /// Represents the high-level state of the provisioning application.
    enum AppState: Equatable {
        case signedOut
        case loading
        case signedIn(SignedInState)
    }

    enum SignedInState: Equatable {
        case banner
        case home
    }

    /// Represents the specific provisioning status of a card across devices.
    enum CardState: Equatable {
        typealias HasWatch = Bool
        typealias CanAddToWatch = Bool
        typealias CanAddToPhone = Bool
        typealias IsOnPhoneAndWatch = Bool
        typealias PassURL = URL

        case canProvision(HasWatch, CanAddToWatch, CanAddToPhone)
        case provisioned(IsOnPhoneAndWatch, PassURL?)
        case cannotProvision

        /// A human-readable description of the card's current availability.
        var text: String {
            switch self {
            case let .canProvision(hasWatch, canAddToWatch, canAddToPhone):
                if canAddToPhone, canAddToWatch {
                    return "Card can be added to your phone and watch."
                } else if !canAddToPhone, canAddToWatch {
                    return "Card is already on your phone and can also be added to your watch."
                } else if canAddToPhone, hasWatch, !canAddToWatch {
                    return "Card is already on your watch and can also be added to your phone."
                } else if canAddToPhone {
                    return "Card can be added to your phone."
                } else {
                    return "Card cannot be added to Apple Wallet."
                }

            case let .provisioned(isOnPhoneAndWatch, _):
                return isOnPhoneAndWatch
                    ? "Card is available on your phone and watch."
                    : "Card is available on your phone."

            case .cannotProvision:
                return "Card cannot be added to Apple Wallet."
            }
        }
    }
}

extension ViewModel.CardState {
    /// Indicates whether an Apple Watch is part of the current provisioning state.
    ///
    /// For `.canProvision`, this reflects whether a watch is available for provisioning.
    /// For `.provisioned`, this reflects whether the card is provisioned on both phone and watch.
    var hasWatch: Bool {
        switch self {
        case let .canProvision(hasWatch, _, _):
            return hasWatch
        case let .provisioned(isOnPhoneAndWatch, _):
            return isOnPhoneAndWatch
        case .cannotProvision:
            return false
        }
    }
}

// MARK: - UIApplication Extension

extension UIApplication {
    /// Retrieves the top-most active view controller in a multi-scene environment.
    var topMostViewController: UIViewController? {
        let rootViewController = connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController

        return rootViewController?.topMostPresentedViewController()
    }
}

private extension UIViewController {
    /// Walks the presented controller hierarchy and returns the most visible view controller.
    func topMostPresentedViewController() -> UIViewController {
        if let presentedViewController {
            return presentedViewController.topMostPresentedViewController()
        }

        if let navigationController = self as? UINavigationController,
           let visibleViewController = navigationController.visibleViewController {
            return visibleViewController.topMostPresentedViewController()
        }

        if let tabBarController = self as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return selectedViewController.topMostPresentedViewController()
        }

        return self
    }
}
