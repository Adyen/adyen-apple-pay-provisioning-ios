# Adyen Apple Pay Provisioning

`Adyen Apple Pay Provisioning` iOS SDK simplifies integration with Apple wallet. 

## Installation

The SDK is available via `Swift Package Manager` or via manual installation.

### Swift Package Manager

1. Follow Apple's [Adding Package Dependencies to Your App](
https://developer.apple.com/documentation/xcode/adding_package_dependencies_to_your_app
) guide on how to add a Swift Package dependency.
2. Use `https://github.com/Adyen/adyen-apple-pay-provisioning-ios` as the repository URL.

### Dynamic xcFramework

Drag the dynamic `AdyenApplePayProvisioning/XCFramework/Dynamic/AdyenApplePayProvisioning.xcframework` and `AdyenApplePayExtensionProvisioning/XCFramework/Dynamic/AdyenApplePayExtensionProvisioning.xcframework` (wallet extension) to the `Frameworks, Libraries, and Embedded Content` section in your general target settings. Select "Copy items if needed" when asked.

### Static xcFramework

1. Drag the static `AdyenApplePayProvisioning/XCFramework/Static/AdyenApplePayProvisioning.xcframework` and `AdyenApplePayExtensionProvisioning/XCFramework/Static/AdyenApplePayExtensionProvisioning.xcframework` (wallet extension) to the `Frameworks, Libraries, and Embedded Content` section in your general target settings.
2. Make sure the static `AdyenApplePayProvisioning.xcframework` and `AdyenApplePayExtensionProvisioning.xcframework` is not embedded.
3. Select `AdyenApplePayProvisioning.bundle` inside `AdyenApplePayProvisioning.xcframework` (same for extension) and check "Copy items if needed", then select "Add".

## Usage

### Creating a provisioning service instance

Create an instance of `ProvisioningService` with the sdk input data retrieved from the call to `/paymentInstruments/\(paymentInstrumentId)/networkTokenActivationData`.
```swift
provisioningService = try ProvisioningService(sdkInput: sdkInput)

```

### Checking if a card can be added

Check if the cardholder can add a payment card to their Apple Wallet (phone or watch). If the card cannot be added it means it is already in the wallet. However, when the watch is not available it is not possible to determine if that card is already added. Watch availability needs to be determined on the caller's side by using `WCSession` or the `WatchAvailability` class.
```swift
let watchAvailability = WatchAvailability()
let isWatchActivated = await watchAvailability.activate()
let state = provisioningService.canAddCardDetails(isWatchActivated: isWatchActivated)

if state.canAddCard {
    // show "Add to Apple Wallet" button
}
```
**Tip:** If you have provisioned a card on your device and it appears in the wallet but `canAddCard` is still `true`, it is very likely the card configuration profile is not complete on the Card Network side (Visa, Mastercard).

### Initiate card provisioning

When the cardholder selects `Add card to Apple Wallet`, initiate provisioning by calling the `start()` method with two parameters: `delegate` and `presentingViewController`
```swift
try provisioningService.start(
    delegate: self,
    presentingViewController: viewController
)
```

### Provision the card

Implement `ProvisioningServiceDelegate` to receive the `provision(sdkOutput)` callback from the `SDK`. In the callback:

1. From your back-end, make a `POST` `paymentInstruments/{id}/networkTokenActivationData` request and pass sdkOutput to provision the payment instrument. The response contains the `sdkInput` object.
2. Return `sdkInput` from the `provision` method.

```swift
func provision(sdkOutput: Data, paymentInstrumentId: String) async -> Data? {
    struct ProvisioningBody: Encodable {
        let sdkOutput: Data
    }

    let encoder = JSONEncoder()
    encoder.dataEncodingStrategy = .base64

    do {
        let body = try encoder.encode(ProvisioningBody(sdkOutput: sdkOutput))
        let sdkInput = // POST the body to the server and receive `sdkInput` back
        return sdkInput
    } catch {
        return nil
    }
}
```

### Finalize card provisioning

When the provisioning is complete update your UI
```swift
func didFinishProvisioning(with pass: PKPaymentPass?, error: Error?) {
    // Update your UI
}
```

### Handle provisioning flow from the `Wallet` app (wallet extension)

In your wallet extension target create a subclass of `PKIssuerProvisioningExtensionHandler` which conforms to `ExtensionProvisioningServiceDelegate` protocol. Implement required methods (override parent class methods and implement protocol methods) and pass the data provided by the SDK.
```swift
import PassKit
import AdyenApplePayExtensionProvisioning

class ActionRequestHandler: PKIssuerProvisioningExtensionHandler, ExtensionProvisioningServiceDelegate {
    // Your implementation goes here
}
```

## See also

 * [Full documentation at Adyen](https://docs.adyen.com/issuing/digital-wallets/apple-pay-provisioning/)
 * [Full documentation for this version](https://adyen.github.io/adyen-apple-pay-provisioning-ios/2.0.0/Api)
 * [SDK reference Adyen Apple Pay Provisioning](https://adyen.github.io/adyen-apple-pay-provisioning-ios/2.0.0/AdyenApplePayProvisioning/documentation/adyenapplepayprovisioning/)
 * [SDK reference Adyen Apple Pay Extension Provisioning](https://adyen.github.io/adyen-apple-pay-provisioning-ios/2.0.0/AdyenApplePayExtensionProvisioning/documentation/adyenapplepayextensionprovisioning/)
 * [Data security at Adyen](https://docs.adyen.com/development-resources/adyen-data-security)

## License

This SDK is available under the MIT License. For more information, see the [LICENSE](https://github.com/Adyen/adyen-apple-pay-provisioning-ios/blob/main/LICENSE) file.
