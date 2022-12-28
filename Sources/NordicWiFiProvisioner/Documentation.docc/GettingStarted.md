# Getting Started

Discover, connect, and provision Nordic devices using the NordicWiFiProvisioner library.

## Overview

`NordicWiFiProvisioner` allows you to provision an nRF-7 Series device with a WiFi network, read the device information, and scan for nearby WiFi networks.
It uses CoreBluetooth to communicate with the device, so you have to test your app on a real device.
However, you can use ``MockManager`` to start developing your app without a real device. For more information, see <doc:Mocking>.

> Important: Using CoreBluetooth requires adding [NSBluetoothAlwaysUsageDescription](https://developer.apple.com/documentation/bundleresources/information_property_list/nsbluetoothalwaysusagedescription) key to your Info.plist file.

## Scaner
`NordicWiFiProvisioner` provides a ``Scanner`` class that you can use to scan for nRF-7 Series devices. This class makes all the necessary BLE calls to scan for devices and filter them.

### Using Scanner
To scan for devices, you have to create an instance of ``Scanner`` and set its delegate. 

```swift
class ViewModel: ScannerDelegate {
    var scanResults: [ScanResult] = []
    let scanner: NordicWiFiProvisioner.Scanner
    
    init() {
        self.scanner = Scanner()
        self.scanner.delegate = self
    }
}
```

The delegate has 2 methods for tracking the scanning process.

```swift
extension ViewModel {
    func scannerStartedScanning() {
        print("Started Scanning")
    }
    
    func scannerStoppedScanning() {
        print("Stopped Scanning")
    }
}
```

You can also watch for new scanner state.

```swift
extension ViewModel {
    func scannerDidUpdateState(_ state: NordicWiFiProvisioner.Scanner.State) {
        switch state {
        case .poweredOn:
            print("Powered On")
        case .poweredOff:
            print("Powered Off")
        case .resetting:
            print("Resetting")
        case .unauthorized:
            print("Unauthorized")
        case .unknown:
            print("Unknown")
        case .unsupported:
            print("Unsupported")
        }
    }
}
```

Finally, you can receive scan results by implementing ``ScannerDelegate/scannerDidDiscover(_:)``

```swift
extension ViewModel {
    func scannerDidDiscover(_ scanResult: ScanResult) {
        let id = scanResult.id
        let name = scanResult.name
        let version = scanResult.version
        let rssi = scanResult.rssi
        let wifiRSSI = scanResult.wifiRSSI
        let connected = scanResult.connected
        let provisioned = scanResult.provisioned
        
        // Check if the device is already in the list.
        if let existingElementIndox = scanResults.firstIndex(where: { $0.id == id }) {
            self.scanResults[existingElementIndox] = scanResult
        } else {
            self.scanResults.append(scanResult)
        }
    }
}
```

> Note: You can get the same result in ``ScannerDelegate/scannerDidDiscover(_:)``, so you have to check if you already have the device if you store the results in some collection and update it.