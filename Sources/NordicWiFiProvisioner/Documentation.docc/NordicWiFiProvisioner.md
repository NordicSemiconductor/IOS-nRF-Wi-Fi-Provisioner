# ``NordicWiFiProvisioner``

`NordicWiFiProvisioner` allows you to provision an nRF-7 Series device with a WiFi network, read the device information, and scan for nearby WiFi networks.

`NordicWiFiProvisioner` provides classes needed to scan for nRF-7 Series devices and provision them with a WiFi network. It also allows you to read the device information like version or current WiFi connection status and scan for nearby WiFi networks using an nRF device as a WiFi scanner.

The library itself is straightforward and easy to use. 

You can implement your own scanner, but the library provides a ``Scanner`` class that you can use to scan for nRF-7 Series devices. This class makes all the necessary BLE calls to scan for devices and filter them.

> Important: Though the library doesn't require import `CoreBluetooth` it uses it inside, so you still have to add [NSBluetoothAlwaysUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nsbluetoothalwaysusagedescription) key to your Info.plist file.

``DeviceManager`` class is a multi purpose class that allows you to read information from the device, scan for nearby WiFi networks, and provision the device with a WiFi network.

## Topics

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
