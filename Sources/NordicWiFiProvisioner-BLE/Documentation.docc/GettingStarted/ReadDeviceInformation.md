# Read Device Information

Read version and device status from the device.

## Overview

After you connect to the device, you can read the device information.

You can use ``DeviceManager/readVersion()`` to read the version of the firmware running on the device.

To get the device status, use ``DeviceManager/readDeviceStatus()``.

## Information Delegate

Before reading version or status, you need to set the information delegate to receive the information.

You need to implement 2 methods:
* ``InfoDelegate/versionReceived(_:)`` - Called when the version is received.
* ``InfoDelegate/deviceStatusReceived(_:)`` - Called when the device status is received.

```swift
class ViewModel {
    // Create an instance of DeviceManager.

    func setupDeviceManager() {
        // . . .

        // Set the information delegate.
        deviceManager.informationDelegate = self

        // . . .
    }
}

extension ViewModel: InfoDelegate {
    func versionReceived(_ version: Result<Int, NordicWiFiProvisioner.ProvisionerInfoError>) {
        // Handle the version result.
    }
    
    func deviceStatusReceived(_ status: Result<NordicWiFiProvisioner.DeviceStatus, NordicWiFiProvisioner.ProvisionerError>) {
        // Handle the device status result.
    }
}
```

Both methods get a [Result](https://developer.apple.com/documentation/swift/result) as a parameter. The `Result` contains the value or the error.

## Read the information

After setting the information delegate, you can read the version and device status.

```swift

class ViewModel {
    func readInformation() {
        // . . .
        do {
            // Read the version.
            try deviceManager.readVersion()
            // Read the device status.
            try deviceManager.readDeviceStatus()
        } catch {
            // Handle `DeviceNotConnectedError` error.
        }

        // . . .
    }
}
```

> Note: All methods that are supposed to be called after connecting to the device, will return ``DeviceNotConnectedError`` if you call them before connecting to the device.