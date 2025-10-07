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

Drag the dynamic `AdyenApplePayProvisioning/XCFramework/Dynamic/AdyenApplePayProvisioning.xcframework` and `AdyenApplePayExtensionProvisioning/XCFramework/Dynamic/AdyenApplePayExtensionProvisioning.xcframework` (wallet extension) to the **Frameworks, Libraries, and Embedded Content** section in your target's general settings. Select **Copy items if needed** when asked.

### Static xcFramework

1. Drag the static `AdyenApplePayProvisioning/XCFramework/Static/AdyenApplePayProvisioning.xcframework` and `AdyenApplePayExtensionProvisioning/XCFramework/Static/AdyenApplePayExtensionProvisioning.xcframework` (wallet extension) to the **Frameworks, Libraries, and Embedded Content** section in your target's general settings.
2. Ensure the static frameworks are set to **Do Not Embed**.
3. For both `AdyenApplePayProvisioning.xcframework` and `AdyenApplePayExtensionProvisioning.xcframework`, locate the `.bundle` file inside. Drag each bundle into your target, select **Copy items if needed**, and click **Add**.

## Usage

### Creating a provisioning service instance

Create an instance of `ProvisioningService` using the `sdkInput` data retrieved from your backend's call to the `/paymentInstruments/{paymentInstrumentId}/networkTokenActivationData` endpoint.
```swift
provisioningService = try ProvisioningService(sdkInput: sdkInput)

```

### Checking if a card can be added

Check if the cardholder can add a payment card to their Apple Wallet on the current device or a paired Apple Watch. If the card cannot be added, it means it's already in the Wallet. However, it's not possible to check the status of a paired watch if it's unavailable. You must determine watch availability using `WCSession` or our provided `WatchAvailability` helper class.
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

When the cardholder taps **Add to Apple Wallet**, initiate provisioning by calling the `start()` method, passing a `delegate` and a `presentingViewController`.
```swift
try provisioningService.start(
    delegate: self,
    presentingViewController: viewController
)
```

### Provision the card

Implement `ProvisioningServiceDelegate` to receive the `provision(sdkOutput:)` callback from the SDK. In this callback:

1. From your backend, make a `POST` request to the `paymentInstruments/{id}/networkTokenActivationData` endpoint. Include the `sdkOutput` from the delegate method in your request body to provision the payment instrument. The response from your backend will contain a new `sdkInput` object.
2. Return the new `sdkInput` from the `provision` method.

```swift
func provision(sdkOutput: Data, paymentInstrumentId: String) async -> Data? {
    struct ProvisioningRequestBody: Encodable {
        let sdkOutput: Data
    }
    
    // The server sends sdkInput as a Base64 encoded string; JSONDecoder decodes it into a Data object.
    struct ProvisioningResponse: Decodable {
        let sdkInput: Data
    }

    do {
        let encoder = JSONEncoder()
        encoder.dataEncodingStrategy = .base64
        let body = try encoder.encode(ProvisioningRequestBody(sdkOutput: sdkOutput))
        
        // TODO: POST the body to your server and receive data back.
         
        let decoder = JSONDecoder()
        decoder.dataDecodingStrategy = .base64
        let response = try decoder.decode(ProvisioningResponse.self, from: data)
        return response.sdkInput
    } catch {
        return nil
    }
}
```

### Finalize card provisioning

When provisioning is complete, update your UI in the `didFinishProvisioning` delegate method.
```swift
func didFinishProvisioning(with pass: PKPaymentPass?, error: Error?) {
    // Update your UI
}
```

### Handle provisioning flow from the `Wallet` app (wallet extension)

In your wallet extension target, create a subclass of `PKIssuerProvisioningExtensionHandler` that conforms to the `ExtensionProvisioningServiceDelegate` protocol. You'll need to implement the required delegate and superclass methods, passing along the data provided by the SDK.

```swift
import PassKit
import AdyenApplePayExtensionProvisioning

class ActionRequestHandler: PKIssuerProvisioningExtensionHandler, ExtensionProvisioningServiceDelegate {
    // Your implementation goes here
}
```

### Testing

Card provisioning only works on App Store builds (including TestFlight) with Adyen cards on the **Live** environment. The app must be built with the development team account for which the **In-App Provisioning** entitlement was granted. This entitlement must be set for all relevant targets (your app, wallet extension, and wallet UI extension). The provisioning flows should be built based on the provided UX guidelines. Test all flows thoroughly before going live.

## See also

 * [Full documentation for this version](https://adyen.github.io/adyen-apple-pay-provisioning-ios/2.1.0/Api)
 * [SDK reference Adyen Apple Pay Provisioning](https://adyen.github.io/adyen-apple-pay-provisioning-ios/2.1.0/AdyenApplePayProvisioning/documentation/adyenapplepayprovisioning/)
 * [SDK reference Adyen Apple Pay Extension Provisioning](https://adyen.github.io/adyen-apple-pay-provisioning-ios/2.1.0/AdyenApplePayExtensionProvisioning/documentation/adyenapplepayextensionprovisioning/)
 * [Data security at Adyen](https://docs.adyen.com/development-resources/adyen-data-security)

## License

This SDK is available under the MIT License. For more information, see the [LICENSE](https://github.com/Adyen/adyen-apple-pay-provisioning-ios/blob/main/LICENSE) file.
