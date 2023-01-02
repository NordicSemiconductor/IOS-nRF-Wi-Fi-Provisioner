# Getting Started

Discover, connect, and provision Nordic devices using the NordicWiFiProvisioner library.

## Overview

`NordicWiFiProvisioner` allows you to provision an nRF-7 Series device with a WiFi network, read the device information, and scan for nearby WiFi networks.
It uses CoreBluetooth to communicate with the device, so you have to test your app on a real device.
However, you can use ``MockManager`` to start developing your app without a real device. For more information, see <doc:Mocking>.

> Important: Using CoreBluetooth requires adding [NSBluetoothAlwaysUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nsbluetoothalwaysusagedescription) key to your Info.plist file.

## Topics

### Scanning
- <doc:Scanning>

### Using Device Manager
- <doc:ConnectToDevice>
- <doc:ReadDeviceInformation>
- <doc:WiFiScanning>

### Enabling Mocks
- <doc:Mocking>
