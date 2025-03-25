//
//  WalletUIExtension.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2025 Adyen N.V.
//

import Foundation
import PassKit
import SwiftUI
import UIKit

// This class gets initialized when `WalletExtension` requires authentication.
// The provided UI will be presented to the user - if authentication succeeds the
// `completionHandler` needs to pass `.authorized` result and the card provisioning will continue.
class WalletUIExtension: UIViewController, PKIssuerProvisioningExtensionAuthorizationProviding {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        let wrapper = SignInViewWrapper { [weak self] authenticated in
            let result: PKIssuerProvisioningExtensionAuthorizationResult = authenticated ? .authorized : .canceled
            self?.completionHandler?(result)
        }

        addChild(wrapper)
        view.addSubview(wrapper.view)
        wrapper.view.frame = view.bounds
        wrapper.didMove(toParent: self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        children.first?.view.frame = view.bounds
    }

    @available(*, unavailable)
    @MainActor @objc dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var completionHandler: ((PKIssuerProvisioningExtensionAuthorizationResult) -> Void)?
}

class SignInViewWrapper: UIHostingController<SignInView> {
    init(authenticated: @escaping (Bool) -> Void) {
        super.init(rootView: SignInView(completion: authenticated))

        isModalInPresentation = true // Prevent interactive dismissal
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
