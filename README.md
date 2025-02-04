# iOS SDK for Mileus Watchdog

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Pods compatible](https://img.shields.io/cocoapods/v/MileusWatchdogKit.svg?style=flat)](https://cocoapods.org/pods/MileusKit)
[![SPM compatible](https://img.shields.io/badge/SPM-supported-DE5C43.svg?style=flat)](https://swift.org/package-manager)
[![Platform](https://img.shields.io/cocoapods/p/LFAlertController.svg?style=flat)](https://github.com/skoumalcz)
[![Swift Version](https://img.shields.io/badge/swift-5.1-orange.svg)](https://swift.org/)

This library supports an asynchronous background search for journey plans through Mileus, with the base use case of commuting home from the user's current location.

Please see the [Watchdog search docs](https://docs.mileus.com/watchdog-search/) for more details about the functionality, or the [SDK docs](https://docs.mileus.com/watchdog-search/frontend-integration/sdk/ios/) for more details about the usage of this SDK.

## Requirements
- iOS 11.0+
- Xcode 11.0+
- Swift 5.0+

## Installation

### Carthage
```
github "mileus/watchdog-sdk-ios" ~> 1.0.2
```

### Cocoapods
```
pod 'MileusWatchdogKit', '~> 1.0'
```

### Swift Package Manager
We are waiting for Swift 5.3 official release. It does not work yet.
```
dependencies: [
    .package(url: "https://github.com/mileus/watchdog-sdk-ios.git", .upToNextMajor(from: "1.0.2"))
]
```

## Configuration
First you need to configure Mileus SDK in your `AppDelegate.application(:, didFinishLaunchingWithOptions:)`
``` swift
MileusWatchdogKit.configure(
    partnerName: String, // Unique partner identifier
    accessToken: String, // Token from Watchdog Auth API
    environment: MileusWatchdogEnvironment // Environment type (staging or production)
) // throws exception (MileusWatchdogError.invalidInput) if partnerName or accessToken is an empty string
```

## Usage

### Start Mileus Watchdog screen
This is a universal entry point in Mileus Watchdog. Use it to initialise new search, as well as opening Mileus Watchdog from notification.

You have to keep a reference to `mileusWatchdogSearch` instance as long as you need it.
``` swift
let mileusWatchdogSearch = MileusWatchdogSearch(
    delegate: MileusWatchdogSearchFlowDelegate,
    origin: MileusWatchdogLocation? = nil, 
    destination: MileusWatchdogLocation? = nil 
) // throws exception (MileusWatchdogError.instanceAlreadyExists) if you have already created an instance or exception (MileusWatchdogError.sdkIsNotInitialized) if you have not initialized sdk yet.
```

Show Mileus Watchdog screen:
``` swift
let mileusVC = mileusWatchdogSearch.show(from: UIViewController)
```

#### Search Flow Delegate
Methods of Flow Delegate are always called on the main thread.
``` swift
protocol MileusWatchdogSearchFlowDelegate {
    func mileus(_ mileus: MileusWatchdogSearch, showSearch data: MileusWatchdogSearchData)
    func mileusShowTaxiRide(_ mileus: MileusWatchdogSearch)
    func mileusShowTaxiRideAndFinish(_ mileus: MileusWatchdogSearch)
    func mileusDidFinish(_ mileus: MileusWatchdogSearch)
}
```

#### Search for origin or destination
``` swift
func mileus(_ mileus: MileusWatchdogSearch, showSearch data: MileusWatchdogSearchData)
```

When it is called you should open your search view controller.

Update origin or destination according to user’s choice:

``` swift
mileusWatchdogSearch.updateOrigin(location: MileusWatchdogLocation)
mileusWatchdogSearch.updateDestination(location: MileusWatchdogLocation)
```

#### Open taxi ride Activity
``` swift
func mileusShowTaxiRide(_ mileus: MileusWatchdogSearch)
```

When it is called you should open your taxi ride view controller.

#### Open taxi ride and finish
``` swift
func mileusShowTaxiRideAndFinish(_ mileus: MileusWatchdogSearch)
```

When it is called you should close `mileusVC` and open your taxi ride view controller.
You get `mileusVC` after calling `mileusWatchdogSearch.show(from:)`.

#### Finish
``` swift
func mileusDidFinish(_ mileus: MileusWatchdogSearch)
```

You are responsible for closing `mileusVC`. You get `mileusVC` after calling `mileusWatchdogSearch.show(from:)`.

### Start Mileus Market Validation screen
Special entry point for market validation purposes. In this mode no callbacks are called. You only need to init Mileus SDK and use one of the following methods to open the market validation screen. 

You have to keep a reference to `mileusMarketValidation` instance as long as you need it.
``` swift
let mileusMarketValidation = MileusMarketValidation(
    delegate: MileusMarketValidationFlowDelegate,
    origin: MileusWatchdogLocation, 
    destination: MileusWatchdogLocation 
) // throws exception (MileusWatchdogError.instanceAlreadyExists) if you have already created an instance or exception (MileusWatchdogError.sdkIsNotInitialized) if you have not initialized sdk yet.
```

Show Mileus Market Validation screen:
``` swift
let mileusVC = mileusMarketValidation.show(from: UIViewController)
```

#### Market Validation Flow Delegate
Methods of Flow Delegate are always called on the main thread.

``` swift
protocol MileusMarketValidationFlowDelegate {
    func mileusDidFinish(_ mileus: MileusMarketValidation)
}
```

#### Finish
``` swift
func mileusDidFinish(_ mileus: MileusMarketValidation)
```

You are responsible for closing `mileusVC`. You get `mileusVC` after calling `mileusMarketValidation.show(from:)`.

## Models

### Classes

#### Mileus Watchdog Search
``` swift
class MileusWatchdogSearch {
    init(delegate: MileusWatchdogSearchFlowDelegate, 
    origin: MileusWatchdogLocation? = nil, 
    destination: MileusWatchdogLocation? = nil
    )

    func show(from: UIViewController) -> UIViewController
    func updateOrigin(location: MileusWatchdogLocation)
    func updateDestination(location: MileusWatchdogLocation)
}
```

#### Mileus Market Validation
``` swift
class MileusMarketValidation {
    init(delegate: MileusMarketValidationFlowDelegate, 
    origin: MileusWatchdogLocation, 
    destination: MileusWatchdogLocation
    )

    func show(from: UIViewController) -> UIViewController
}
```

### Delegates
Methods of Flow Delegate are always called on the main thread.

#### Search Flow Delegate
``` swift
protocol MileusWatchdogSearchFlowDelegate {
    func mileus(_ mileus: MileusWatchdogSearch, showSearch data: MileusWatchdogSearchData)
    func mileusShowTaxiRide(_ mileus: MileusWatchdogSearch)
    func mileusShowTaxiRideAndFinish(_ mileus: MileusWatchdogSearch)
    func mileusDidFinish(_ mileus: MileusWatchdogSearch)
}
```

#### Market Validation Flow Delegate
``` swift
protocol MileusMarketValidationFlowDelegate {
    func mileusDidFinish(_ mileus: MileusMarketValidation)
}
```

### Data
#### Search Data
``` swift
struct MileusWatchdogSearchData {
    let type: MileusWatchdogSearchType
    let origin: MileusWatchdogLocation
    let destination: MileusWatchdogLocation
}
```

#### Location
``` swift
struct MileusWatchdogLocation {
    let address: String
    let latitude: Double
    let longitude: Double
    let accuracy: Float
    
    init(address: String, 
         latitude: Double, 
         longitude: Double, 
         accuracy: Float = 0.0)
}
```

### Enums
#### Environment
``` swift
enum MileusWatchdogEnvironment {
    case development
    case staging
    case production
}
```

#### Search Type
``` swift
enum MileusWatchdogSearchType {
    case origin
    case destination
}
```

### Errors
``` swift
enum MileusWatchdogError: Error {
    case invalidInput
    case instanceAlreadyExists
    case sdkIsNotInitialized
    case unknown
}
```
