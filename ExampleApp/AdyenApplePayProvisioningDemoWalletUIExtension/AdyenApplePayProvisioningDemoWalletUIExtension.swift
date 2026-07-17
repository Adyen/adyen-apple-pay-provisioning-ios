//
//  AdyenApplePayProvisioningDemoWalletUIExtension.swift
//  Adyen Apple Pay Provisioning
//
//  Copyright (c) 2026 Adyen N.V.
//

import Foundation
import PassKit
import SwiftUI
import UIKit

/// This class gets initialized when `WalletExtension` requires authentication.
/// The provided UI will be presented to the user - if authentication succeeds the
/// `completionHandler` needs to pass `.authorized` result and the card provisioning will continue.
class AdyenApplePayProvisioningDemoWalletUIExtension: UIViewController, PKIssuerProvisioningExtensionAuthorizationProviding {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        let wrapper = AuthFlowViewWrapper { [weak self] authenticated in
            if authenticated {
                SessionStore().setSignedIn(true)
            }
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
        guard let child = children.first else { return }
        var frame = view.bounds
        frame.size.height = max(frame.size.height, child.view.frame.height)
        child.view.frame = frame
    }

    @available(*, unavailable)
    @MainActor @objc dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var completionHandler: ((PKIssuerProvisioningExtensionAuthorizationResult) -> Void)?
}

class AuthFlowViewWrapper: UIHostingController<AuthFlowView> {
    init(authenticated: @escaping (Bool) -> Void) {
        super.init(rootView: AuthFlowView(completion: authenticated))

        isModalInPresentation = true // Prevent interactive dismissal
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
