# ``NordicWiFiProvisioner``

`NordicWiFiProvisioner` allows you to provision an nRF-7 Series device with a WiFi network, read the device information, and scan for nearby WiFi networks.

The library is easy to use and provides all the necessary classes and methods to communicate with the device.

`NordicWiFiProvisioner` provides classes needed to scan for nRF-7 Series devices and provision them with a WiFi network. It also allows you to read the device information like version or current WiFi connection status and scan for nearby WiFi networks using an nRF device as a WiFi scanner.

> Important: Though the library doesn't require import `CoreBluetooth` it uses it inside, so you still have to add [NSBluetoothAlwaysUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nsbluetoothalwaysusagedescription) key to your Info.plist file.

## Topics

### Getting Started
- <doc:GettingStarted>

### Constants
- ``ServiceID``
- ``CharacteristicID``

### Scanner

- ``Scanner``
- ``ScannerDelegate``
- ``ScanResult``

### Device Manager

- ``DeviceManager``
- ``ConnectionDelegate``
- ``InfoDelegate``
- ``WiFiScanerDelegate``
- ``ProvisionDelegate``

### Errors

- ``DeviceNotConnectedError``
- ``ConnectionFailureReason``
- ``ProvisionerError``
- ``ProvisionerInfoError``

### Device Information
- ``DeviceStatus``
- ``ConnectionInfo``
- ``ConnectionState``
- ``IPAddress``
- ``ScanParams``

### WiFi Network Information
- ``WifiInfo``
- ``MACAddress``
- ``AuthMode``
- ``Band``

### Mocking
- ``MockManager``
- ``MockDevice``
- ``MockProvisionDelegate``
- ``MockScanResultProvider``
- ``WiFiScanResultFaker``
