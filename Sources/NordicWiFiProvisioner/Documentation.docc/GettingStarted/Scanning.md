# Scanning for nRF-7 Series Devices
Use ``Scanner`` to scan for nRF-7 Series devices.

## Overview

`NordicWiFiProvisioner` provides a ``Scanner`` class that you can use to scan for nRF-7 Series devices. This class makes all the necessary BLE calls to scan for devices and filter them. 

## Using Scanner
### Create an Instance
To scan for devices, you have to create an instance of ``Scanner`` and set its ``Scanner/delegate``. 

```swift
class ViewModel: ScannerDelegate {
    var scanResults: [ScanResult] = []
    let scanner: NordicWiFiProvisioner.Scanner
    
    init() {
        self.scanner = Scanner()

        // Set the delegate to receive state updates and scan results.
        self.scanner.delegate = self
    }
}
```

### Check Scanner State
You can also watch for new scanner state. The new state is received in ``ScannerDelegate/scannerDidUpdateState(_:)``. This state represesnts the state of the `CoreBluetooth` manager.

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

### Start Scanning

To start scanning, call ``Scanner/startScan()``.

The delegate has 2 methods for tracking the scanning process: ``ScannerDelegate/scannerStartedScanning()`` and ``ScannerDelegate/scannerStoppedScanning()``.

```swift
extension ViewModel {
    func startScan() {
        scanner.startScan()
    }

    func scannerStartedScanning() {
        print("Started Scanning")
    }
    
    func scannerStoppedScanning() {
        print("Stopped Scanning")
    }
}
```

### Receive Scan Results
You can receive scan results by implementing ``ScannerDelegate/scannerDidDiscover(_:)``

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

> Note: You can get the same result in ``ScannerDelegate/scannerDidDiscover(_:)`` few times, so you have to check if you already have the device if you store the results in some collection and update it.

## Creating a custom Scanner 
You can create your own scanner. To do this, you have to create instance of `CBCentralManager` and scan for the devices.
You can use ``ServiceID/wifi`` service identifier to filter the results.

```swift
class CustomScanner: NSObject {
    /// Create instance of CBCentralManager and set its delegate.
}

extension CustomScanner: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        central.scanForPeripherals(withServices: [CBUUID(nsuuid: ServiceID.wifi)])
    }
}
```

