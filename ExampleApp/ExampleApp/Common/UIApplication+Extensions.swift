//
//  UIApplication+Extensions.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2024 Adyen N.V.
//

import Foundation
import UIKit

extension UIApplication {
    var rootViewController: UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState == .foregroundActive }
            .first?.keyWindow?.rootViewController
    }
}
