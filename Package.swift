// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

public let package = Package(
    name: "AdyenApplePayProvisioning",
    platforms: [
        .iOS("13.4")
    ],
    products: [
        .library(
            name: "AdyenApplePayProvisioning",
            targets: ["AdyenApplePayProvisioningBinary"]
        ),
        .library(
            name: "AdyenApplePayExtensionProvisioning",
            targets: ["AdyenApplePayExtensionProvisioningBinary"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "AdyenApplePayProvisioningBinary",
            path: "AdyenApplePayProvisioning/XCFramework/Static/AdyenApplePayProvisioning.xcframework"
        ),
        .binaryTarget(
            name: "AdyenApplePayExtensionProvisioningBinary",
            path: "AdyenApplePayExtensionProvisioning/XCFramework/Static/AdyenApplePayExtensionProvisioning.xcframework"
        )
    ]
)
