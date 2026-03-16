# Adyen Apple Pay Provisioning

In-App Provisioning enables cardholders to add their payment cards to Apple Wallet directly from your app. This feature provides a quick and secure way for users to add their payment information without having to manually enter card details.

-----

## Get the Adyen SDK

The Adyen Apple Pay Provisioning SDK is available on [GitHub](https://github.com/Adyen/adyen-apple-pay-provisioning-ios/). Please follow the `README.md` file for detailed installation instructions.

### System requirements

Before you start, make sure your environment meets the following requirements:

  * Targets **iOS 13.4** or later.
  * **Xcode 14** or later.
  * **Swift 5.7** or later.

-----

### Entitlements

To use In-App Provisioning, you must add the **In-App Provisioning** (`com.apple.developer.payment-pass-provisioning`) entitlement to your App ID. 

> [!IMPORTANT]
> This entitlement must be added to **all targets** involved in the flow: the main App, the Non-UI Extension, and the UI Extension. This can be done manually in your `.entitlements` files or via the **+ Capability** action in each target's **Signing & Capabilities** tab in Xcode.

---

## In-app provisioning

With Apple Pay In-App provisioning, your cardholder can add their card directly from your app. During the In-App flow, the cardholder taps **Add to Apple Wallet** and the provisioning process starts and finishes within your app providing a seamless flow.

The following diagram walks you through the In-App provisioning flow. Green labels correspond to the steps described further on the page:

![](Resources/in-app-flow.svg)


1. [Get activation data](#get-activation-data)
2. [Check if a card can be added](#check-if-a-card-can-be-added)
3. [Initiate card provisioning](#initiate-card-provisioning)
4. [Provision the card](#provision-the-card)
5. [Finalize card provisioning](#finalize-card-provisioning)


### Get activation data

Before you can start card provisioning, you must get activation data for the payment instrument.

1. From your backend, make a `GET` request to the `/paymentInstruments/{id}/networkTokenActivationData` endpoint, specifying the ID of the payment instrument. Your API credential needs the following role:

      * **Bank Issuing PaymentInstrument Network Token Activation Data role**

    ```bash
    curl https://balanceplatform-api-test.adyen.com/bcl/v2/paymentInstruments/{id}/networkTokenActivationData \
    -H 'x-api-key: YOUR_BALANCE_PLATFORM_API_KEY' \
    -H 'content-type: application/json' \
    ```

    The response contains the `sdkInput` object that you need to initialize the SDK in the next step.
    Cache the sdkInput for potential reuse from the wallet extension.

2. Pass the `sdkInput` to your app.

### Check if a card can be added

After receiving the `sdkInput`, initialize the `ProvisioningService`. Use it to check if the cardholder can add the card to Apple Wallet on the current device or a paired Apple Watch. If the card cannot be added, it means it's already in the Wallet. You must determine watch availability yourself, for example by using our provided `WatchAvailability` helper class.

```swift
import AdyenApplePayProvisioning

let provisioningService = try ProvisioningService(sdkInput: sdkInput)
let isWatchActivated = await WatchAvailability.activate()
let state = provisioningService.canAddCardDetails(isWatchActivated: isWatchActivated)

if state.canAddCard {
    // Show "Add to Apple Wallet" button
}
```

Use the `canAddCard` boolean to conditionally show or hide the **Add to Apple Wallet** button in your UI.

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

1.  From your backend, make a `POST` request to the `paymentInstruments/{id}/networkTokenActivationData` endpoint. Include the `sdkOutput` from the delegate method in your request body to provision the payment instrument. The response from your backend will contain a new `sdkInput` object.
2.  Return the new `sdkInput` from the `provision` method.


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

When provisioning is complete, the SDK calls the `didFinishProvisioning` delegate method. Use this callback to update your UI, for example by changing the button text to **Added to Apple Wallet**.

```swift
func didFinishProvisioning(with pass: PKPaymentPass?, error: Error?) {
    // Update your UI
}
```

-----


## Provisioning from the Wallet App

You can also allow cardholders to provision cards directly from the Apple Wallet app. To enable this, you must implement wallet extensions. Your app's name and icon will then appear in the Wallet's "From Apps on Your iPhone" section.

The following diagram walks you through the wallet extension provisioning flow. The green labels correspond to the steps described below:

![](Resources/extension-flow.svg)

1. [Return extension status](#return-extension-status)
2. [Return pass entries](#return-pass-entries)
3. [Provision the card](#provision-the-card-from-the-extension)
4. [Generate a request to add a payment pass](#generate-a-request-to-add-a-payment-pass)


### Before you begin

Before implementing the Wallet provisioning flow:   

1. [Add the Apple Wallet extension](#add-the-apple-wallet-extension).
2. [Add the Apple Wallet UI extension](#add-the-apple-wallet-ui-extension).

#### Add the Apple Wallet extension

1. Add a new extension target to your Xcode project. The best way to create this is by using the **Action Extension** template. This uses a legacy template compatible with Apple Wallet. After creating the target, you can remove all generated files except for the `info.plist`.

2.  Create a `WalletNonUIExtensionHandler` class that is a subclass of `PKIssuerProvisioningExtensionHandler` and conforms to `ExtensionProvisioningServiceDelegate`. The class name in your code **must** match the `NSExtensionPrincipalClass` in the `info.plist`.

3.  In the target's `Info.plist`, find the `NSExtension` dictionary and set the following values:

    |Key|Type|Value|
    |---|---|---|
    | `NSExtensionPointIdentifier` | String | **com.apple.PassKit.issuer-provisioning** |
    | `NSExtensionPrincipalClass` | String | **$(PRODUCT\_MODULE\_NAME).WalletNonUIExtensionHandler** |

4. Make sure to add `In-App Provisioning` entitlement either manually to the target's entitlements file or via Xcode's UI.


```swift
import PassKit

class WalletNonUIExtensionHandler: PKIssuerProvisioningExtensionHandler, ExtensionProvisioningServiceDelegate {
    // Implement the required methods
    // Refer to the example app for implementation details
}
```

#### Add the Apple Wallet UI extension

The Apple Wallet can use an extension from your app to authenticate the cardholder before provisioning.

1.  Add another **Target** to your Xcode project for the UI extension. Repeat the process using the **Action Extension** template for the UI component. In its `Info.plist`, set the following values in the `NSExtension` dictionary:

    |Key|Type|Value|
    |---|---|---|
    | `NSExtensionPointIdentifier` | String | **com.apple.PassKit.issuer-provisioning.authorization** |
    | `NSExtensionPrincipalClass` | String | **$(PRODUCT\_MODULE\_NAME).WalletUIExtensionHandler** |

2.  Create an `WalletUIExtensionHandler` class that is a subclass of `UIViewController` and conforms to the `PKIssuerProvisioningExtensionAuthorizationProviding` protocol. Use the `completionHandler` to communicate the result of the authentication.

### Return extension status

The Wallet app calls your extension with strict time limits. The first method, `status()`, must complete within **100 ms**. Because a network call is not feasible, you must use cached activation data (e.g., stored in the keychain) for this step.

1.  In your main app, save the `sdkInput` after fetching it. Retrieve this stored value in your extension.
2.  Initialize the `ExtensionProvisioningService`.

```swift
import AdyenApplePayExtensionProvisioning

// For one payment instrument:
let provisioningService = try ExtensionProvisioningService(sdkInput: sdkInput)

// For multiple payment instruments:
let provisioningService = try ExtensionProvisioningService(sdkInputs: [sdkInput1, sdkInput2, ...])
```

3. Implement the `status()` method by calling `extensionStatus()` on the SDK. The `status()` method determines whether your app appears in the **From Apps on Your iPhone** section of the Wallet app.

> [!IMPORTANT]
> This method has a strict **100ms execution limit**. You must use cached data here, as network requests will exceed this limit.

Use the `requiresAuthentication` parameter if you have implemented a UI extension to authenticate the cardholder.

```swift
override open func status() async -> PKIssuerProvisioningExtensionStatus {
    // Attempt to initialize the service using cached data only
    guard let service = await provisioningService(retrieveNewData: false) else {
        return ExtensionProvisioningService.entriesUnavailableExtensionStatus
    }

    return service.extensionStatus(requiresAuthentication: true)
}

/// Helper to initialize the service, optionally fetching fresh data from the network.
/// The `WalletNonUIExtensionHandler` is re-instantiated for each method call, so you must re-initialize the SDK each time.
private func provisioningService(retrieveNewData: Bool) async -> ExtensionProvisioningService? {
    // Retrieve the previously saved/cached data
    guard let cachedData = try? YourCustomActivationDataCache().retrieve() else { return nil }

    // For time-sensitive calls (status()), return immediately using cache
    guard retrieveNewData else {
        // Use cached data for time-sensitive calls (e.g., status()).
        return try? ExtensionProvisioningService(sdkInput: cachedActivationData.sdkInput)
    }

    // For other calls (passEntries, remotePassEntries, generateAddPaymentPassRequestForPassEntryWithIdentifier), fetch fresh data and update cache
    guard let freshData = try? await yourNetworkManager.fetchFreshInput(id: cachedData.id) else {
        return nil 
    }
    
    try? YourCustomActivationDataCache().store(freshData)
    return try? ExtensionProvisioningService(sdkInput: freshData.sdkInput)
}
```

### Return pass entries

To return available passes, you must implement `passEntries()` and `remotePassEntries()`. These methods have a **20-second** time limit, which allows for a network call to refresh the `sdkInput`.

1.  From your backend, fetch a fresh `sdkInput` for each payment instrument you want to display.
2.  Initialize the `ExtensionProvisioningService` with the new data.
3.  The Wallet app shows a preview of the card. To provide the card image, implement the `ExtensionProvisioningServiceDelegate` and its `cardArt(paymentInstrumentId:)` method. Return a `CGImage` that accurately represents the payment card.

```swift
func cardArt(paymentInstrumentId: String) -> CGImage {
    // Return card art for the given ID
}
```

4.  Implement `passEntries()` and `remotePassEntries()` by calling the corresponding methods on the SDK and passing your delegate.

```swift
func passEntries() async -> [PKIssuerProvisioningExtensionPassEntry] {
    guard let provisioningService = await provisioningService(retrieveNewData: true) else {
        return []
    }

    return provisioningService.passEntries(withDelegate: self)
}

func remotePassEntries() async -> [PKIssuerProvisioningExtensionPassEntry] {
    guard let provisioningService = await provisioningService(retrieveNewData: true) else {
        return []
    }

    return provisioningService.passEntries(withDelegate: self)
}
```

### Provision the card from the extension

To provision the card when the extension requests it:

1.  Implement `ExtensionProvisioningServiceDelegate` to receive the `provision(paymentInstrumentId:sdkOutput:)` callback.
2.  In the callback, make a `POST` request to your backend with the `sdkOutput` to provision the card.
3.  Return the new `sdkInput` received from your backend.

```swift
func provision(paymentInstrumentId: String, sdkOutput: Data) async -> Data? {
    // Make a network call to your backend with the sdkOutput
    // and return the new sdkInput from the response.
    // This logic is identical to the In-App provisioning flow.
}
```

### Generate a request to add a payment pass

Implement the `generateAddPaymentPassRequestForPassEntryWithIdentifier(...)` method by calling the corresponding method on the SDK. Pass your delegate to handle the provisioning call.

```swift
func generateAddPaymentPassRequestForPassEntryWithIdentifier(
    _ identifier: String,
    configuration: PKAddPaymentPassRequestConfiguration,
    certificateChain certificates: [Data],
    nonce: Data,
    nonceSignature: Data
) async -> PKAddPaymentPassRequest? {
    guard let provisioningService = await provisioningService(retrieveNewData: true) else {
        return nil
    }
    
    return try? await provisioningService.generateAddPaymentPassRequestForPassEntryWithIdentifier(
        identifier,
        configuration: configuration,
        certificateChain: certificates,
        nonce: nonce,
        nonceSignature: nonceSignature,
        delegate: self
    )
}
```
