# AdyenDL for iOS

[![CI Status](http://img.shields.io/travis/Adyen/adyen-dl-ios.svg?style=flat)](https://travis-ci.org/Adyen/AdyenDL)
[![Version](https://img.shields.io/cocoapods/v/AdyenDL.svg?style=flat)](http://cocoapods.org/pods/AdyenDL)
[![License](https://img.shields.io/cocoapods/l/AdyenDL.svg?style=flat)](http://cocoapods.org/pods/AdyenDL)
[![Platform](https://img.shields.io/cocoapods/p/AdyenDL.svg?style=flat)](http://cocoapods.org/pods/AdyenDL)

This repository contains Adyen's Directory Lookup (DL) library for iOS. With DL you can dynamically list all relevant local payment methods for a specific transaction, so your shopper can always pay with the method of his choice. The methods are listed based on the shopper's country, the transaction currency and amount. After the shopper selects a payment method, the SDK provides a redirect URL to the payment method of choice. The redirect URL is loaded in a [SFSafariViewController](https://developer.apple.com/library/ios/documentation/SafariServices/Reference/SFSafariViewController_Ref/) after which the payment method's app is opened if availabe (e.g. for iDEAL). If the method's app is not available, the (mobile optimized) web flow of the method will be shown.

This library is suited for our 250+ local payment methods. For credit card payments, please make use of the [Client Side Encryption library](https://github.com/Adyen/adyen-cse-ios) which enables you to capture credit card details fully in-app.

## Requirements

The AdyenDL-iOS library is written in Swift and is compatible with apps supporting iOS 8.0 and up.

CocoaPods v1.x is the preferred way of installation. If not installed on your machine, you can install it via your terminal:

  `$ sudo gem install cocoapods`.

Although most of the complexity of the integration is wrapped in this library, you also need to set up a merchant server to validate the integrity of each payment request/response. Please find an example of the API for the merchants server [here](https://github.com/Adyen/adyen-dl-ios/blob/master/SERVER.md).

## Installation
For your convenience we've included an example app in this repository that can be used as a reference while integrating. To try an example run in the terminal:

  `pod try AdyenDL`

  To integrate in your existing Xcode project, add to your Podfile:

  `pod 'AdyenDL'`

  To complete the installation execute the following in your terminal:

  `pod install`

## Usage

Create environment configuration and setup payments processor.
```swift
let configuration = Configuration(
    environment: .live,
    paymentSignatureURL: NSURL(string: "ENTER_URL")!,
    paymentResultSignatureURL: NSURL(string: "ENTER_URL")!,
    paymentStatusURL: NSURL(string: "ENTER_URL")!
)

let paymentsProcessor = PaymentsProcessor(configuration: configuration)
```
Create payment object.
```swift
let payment = Payment(
    amount: 1,
    currency: "EUR",
    country: "NL"
)
```
Fetch list of available payment methods.
```swift
paymentsProcessor.fetchPaymentMethodsFor(payment) { (methods, error) in
  //  Present received list of methods on a screen.
  //  ...
}
```

Fetch Payment URL for desired payment method.
```swift
paymentsProcessor.fetchPayURLFor(payment, payingWith: methods[1].issuers![5], completion: { (url, error) in
  //  Open received Payment URL in a browser to continue payment flow.
  //  ...
}
```

## Licence

This repository is open source and available under the MIT license. See the LICENSE file for more info.
