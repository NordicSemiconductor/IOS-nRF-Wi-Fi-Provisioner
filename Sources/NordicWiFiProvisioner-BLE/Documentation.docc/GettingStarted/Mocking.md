# Getting Started with Mocks

Use the `MockManager` class to test your app without a real device.

## Overview

`NordicWiFiProvisioner` uses `CoreBluetooth` to communicate with the nRF-7 Series device. iOS simulators don't support Bluetooth, so you have to test your app on a real device. However, you can use ``MockManager`` to start developing your app without a real device. 

## Enabling Default mocks
If you call ``MockManager/emulateDevices(devices:forceMock:)`` with default `devices` parameter, the `MockManager` will emulate default devices: not provisioned device, provisioned but not connected device, and provisioned and connected device. 

```swift
MockManager.emulateDevices()
```

You can connect to these devices and do everything you would do with a real device.

If you ask them for scanning for nearby WiFi networks, they will return a list of networks from ``WiFiScanResultFaker/allNetworks``.

You can also provision them with a WiFi network. If the network authentication mode is not ``AuthMode/open``, the device will consider password *`Password1`* as a valid password. Otherwise, it will return ``ConnectionFailureReason/authError``.

The device will be provisioned if the credentials are “valid.” Then, it will be connected and get the IP address `192.168.0.1`.

> Important: Though the ``MockManager`` emulates behavior of the nRF-7 Series device, it is still highly recommended to test your app on a real device.

### Force mock
By default, the `MockManager` will use the real `CoreBluetooth` manager if the app is running on a real device.

However, you can force the ``MockManager`` to mock devices by passing `true` to the `forceMock` parameter. It can be useful when you want to test your app on a real device, but you don't have a nRF-7 Series device with you.


```swift
MockManager.emulateDevices(forceMock: true)
```

## Creating custom mocks
You can create custom mocks by passing an array of ``MockDevice`` to the ``MockManager/emulateDevices(devices:forceMock:)`` method.

### Minimum required properties 
The ``MockDevice`` class has 2 required properties: `name` and `version`

```swift
let device = MockDevice(name: "My Mock Devic", version: 1)
```

In this example, the `MockManager` will emulate a device with the name "My Mock Device" and version 1. It will be not provisioned and not connected.

### Mock Provision Delegate
If you want to override the default provisioning behavior of the mock device, you can create a custom ``MockProvisionDelegate`` and pass it to the ``MockDevice``.

```swift
class CustomMockProvisionDelegate: MockProvisionDelegate {
    func provisionResult(wifiConfig: NordicWiFiProvisioner.WifiConfig) -> Result<NordicWiFiProvisioner.ConnectionInfo, NordicWiFiProvisioner.ConnectionFailureReason> {
        // Implement custom behavior
    }
}

// Set the delegate to the device
let delegate = CustomMockProvisionDelegate()
let device = MockDevice(
    name: "Mock Device",
    version: 1,
    provisionDelegate: delegate
)
```

### Mock Search Result Delegate
By default, the ``MockDevice`` will obtain the list of nearby WiFi networks from ``WiFiScanResultFaker/allNetworks``, which is a list of more than 100 networks.

However, you can implement a custom ``MockScanResultProvider`` and pass it to the ``MockDevice``.

Implementation of ``MockScanResultProvider`` should have a list of ``MockScanResultProvider/FakeWiFiScanResult`` which is just a tuple of ``WifiInfo`` and RSSI.


```swift
class CustomSearchResultProvider: MockScanResultProvider {
    var allNetworks: [FakeWiFiScanResult] {
        [
            FakeWiFiScanResult(
                WifiInfo(
                    ssid: "My WiFi",
                    bssid: MACAddress(data: macData),
                    channel: 1)
            ),
            -50 // RSSI
        ]
    }
}

let searchProvider = CustomSearchResultProvider()
let device = MockDevice(
    name: "Mock Device",
    version: 1,
    searchResultProvider: searchProvider
)
```

## See Also

- ``MockManager``
- ``MockDevice``
- ``WiFiScanResultFaker``
