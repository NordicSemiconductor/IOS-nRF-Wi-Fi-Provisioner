# NordicWiFiProvisioner library
`NordicWiFiProvisioner` is a library that allows to communicate with [nRF 7 devices](https://www.nordicsemi.com/Products/nRF7002).
You can use it to connect to a device, read the information from it, and set the Wi-Fi configuration.

## Installation

The library can be installed via [Swift Package Manager](https://swift.org/package-manager/) or [CocoaPods](https://cocoapods.org/).

### Swift Package Manager

The library can also be included as SPM package. Simply add it in Xcode: File -> Swift Packages -> Add package dependency, type https://github.com/NordicSemiconductor/IOS-nRF-Wi-Fi-Provisioner.git and set required version, branch or commit.

If you have Swift.package file, include the following dependency:

```swift
dependencies: [
    // [...]
    .package(name: "NordicWiFiProvisioner", 
             url: "https://github.com/NordicSemiconductor/IOS-nRF-Wi-Fi-Provisioner.git", 
             .upToNextMajor(from: "x.y")) // Replace x.y with your required version
]
```

### CocoaPods
You can install the library using [CocoaPods](https://cocoapods.org/). Add the following line to your `Podfile`:

```ruby
pod 'NordicWiFiProvisioner'
```

and run `pod install` in the directory containing your `Podfile`.

## Usage

### Scanning for devices
The library provides 

## Application

<a href='https://apps.apple.com/app/nrf-wi-fi-provisioner/id1638948698'><img alt='Get it on AppStore' src='docs/app_store_logo.svg' width='250'/></a>

### Flow
The application allows to communicate with a nRF 7 series device.
The main job of the phone is to get status from the device and initiate provisioning or unprovisioning process.

See this [User Guide](docs/iOSProvisioningUserGuide.pdf) with the nice presentation about how to use the application.

#### Obtaining status

1. The phone connects to the selected IoT device and initialise pairing.
2. After successful pairing it downloads current version and status.
3. Based on status - provisioning or unprovisioning process can be initiated. 

#### Provisioning
1. The phone send START_SCAN command to the IoT device and waits for the result.
2. The phone displays the list with result. An user can select Wi-Fi. If Wi-Fi item provides such an option, then there is a possibility to select a specific channel to connect.
3. After selecting interesting Wi-Fi the phone should send STOP_SCAN command.
4. The user needs to provide a password if the selected Wi-Fi is protected.
5. The user selects if the Wi-Fi should be stored in persistent memory which means that Wi-Fi credentials should survive restarting process.
6. Then the user clicks "Provision" button which sends credential to the IoT device and receive connectivity changes from it.
7. When the IoT device is provisioned then the process is finished and a next device can be provisioned.

#### Unprovisioning
1. The phone sends FORGET_CONFIG command and receive success/error result.

### Bluetooth LE Service
Application depends on one service which should be implemented by an IoT device:
```14387800-130c-49e7-b877-2881c89cb258```

#### Characteristics
The service contains 3 characteristics.
1. ```14387801-130c-49e7-b877-2881c89cb258``` - Unprotected version characteristic which return version number. It is reserved for checking supporting version before actual start of work. 
2. ```14387802-130c-49e7-b877-2881c89cb258``` - Protected with pairing control-point characteristic. It is used by the phone to send commands. In indication the command result status is obtained in asynchronous manner.
3. ```14387803-130c-49e7-b877-2881c89cb258``` - Protected with pairing data-out characteristic. In notification the IoT device sends available Wi-Fi items and connectivity status updates.

### Proto files
The communication with the IoT device is handled with the usage of [Proto files](Provisioner/Sources/Provisioner/proto/proto/).
