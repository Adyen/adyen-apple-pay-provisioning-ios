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
            targets: ["AdyenApplePayProvisioning"]
        ),
        .library(
            name: "AdyenApplePayExtensionProvisioning",
            targets: ["AdyenApplePayExtensionProvisioning"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "AdyenApplePayProvisioning",
            path: "AdyenApplePayProvisioning/XCFramework/Dynamic/AdyenApplePayProvisioning.xcframework"
        ),
        .binaryTarget(
            name: "AdyenApplePayExtensionProvisioning",
            path: "AdyenApplePayExtensionProvisioning/XCFramework/Dynamic/AdyenApplePayExtensionProvisioning.xcframework"
        )
    ]
)
