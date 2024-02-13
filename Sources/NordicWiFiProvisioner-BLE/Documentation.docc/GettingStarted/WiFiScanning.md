# Scan for Wi-Fi Networks

Ask the device to scan for nearby Wi-Fi networks.

## Overview

After you connect to the device, you can ask it to scan for nearby Wi-Fi networks. The device will send results back to its delegate. 

## Implementing the Delegate

To receive scan results, you must implement the ``WiFiScanerDelegate`` protocol. The delegate gets the new scan results are available. It's also notified when the scan starts, when it completes, and when it fails.

```swift
extension ViewModel: WiFiScanerDelegate {
    func deviceManager(_ deviceManager: DeviceManager, discoveredAccessPoint wifi: WifiInfo, rssi: Int?) {
        // The new access point is available. You can add it to your list of discovered networks.
    }
    
    func deviceManagerDidStartScan(_ deviceManager: DeviceManager, error: Error?) {
        if let error = error {
            // Handle Error
        } else {
            isScanning = true
        }
    }
    
    func deviceManagerDidStopScan(_ deviceManager:  DeviceManager, error: Error?) {
        if let error = error {
            // Handle Error
        }
        isScanning = false
    }
 }
 ```

> Note: ``WifiInfo`` represents one channel of a Wi-Fi network. If the Access Point has multiple channels, the device will report each channel separately. It can be a good idea to group the channels by the network name (SSID).

## Starting and Stopping the Scan

After you implement the delegate, you can start and stop the scan. Call ``DeviceManager/startScan(scanParams:)`` to start the scan. Call ``DeviceManager/stopScan()`` to stop the scan.

```swift
func startStopScan() {
        do {
            if !isScanning {
                try deviceManager.startScan()
            } else {
                try deviceManager.stopScan()
            }
        } catch {
            // Handle Error
        }
    }
```

### Scan Parameters

You can provide ``ScanParams`` to the scan request to customize the scan. If you don't provide any parameters, the device will use its default scan parameters.

```swift
let scanParams = ScanParams(
    band: .any,         // Scan all bands
    passive: true,      // What `passive` means?
    periodMs: 100,      // Period between scan results are sent?
    groupChannels: 1    // How many channels are grouped together?
)
try deviceManager.startScan(scanParams: scanparams)
```

## See Also
- ``WiFiScanerDelegate``

