# Connect to the device
Connect to the device before you can provision it with a WiFi network.

## Overview

To connect to the device, you must first create an instance of ``DeviceManager``using ``ScanResult`` ar the device identifier.

### Creating a DeviceManager using ScanResult.
If you use ``Scanner`` to scan for devices, you can use the ``ScanResult`` to create an instance of ``DeviceManager``.

```swift
let deviceManager = DeviceManager(scanResult: scanResult)
```

### Creating a DeviceManager using device identifier.
If you implement your own scanner, you can use the device identifier to create an instance of ``DeviceManager``.

```swift
let deviceManager = DeviceManager(deviceId: peripheral.identifier)
```

### Set the connection delegate
Before connecting to the device, you need set the connection delegate to receive connection events.

``ConnectionDelegate`` has 4 methods that you can implement to handle connection process.

``ConnectionDelegate/deviceManager(_:changedConnectionState:)`` is called when the connection state changes.

``ConnectionDelegate/deviceManagerConnectedDevice(_:)`` is called when the device is connected.

``ConnectionDelegate/deviceManagerDidFailToConnect(_:error:)`` is called when the device fails to connect.

``ConnectionDelegate/deviceManagerDisconnectedDevice(_:error:)`` is called when the device is disconnected. The error parameter is nil if the device is disconnected normally.

```swift
class ViewModel {
    // Create an instance of DeviceManager.

    func connect() {
        // . . .

        // Set the connection delegate.
        deviceManager.connectionDelegate = self

        // . . .
    }
}

extension ViewModel: ConnectionDelegate {
    func deviceManagerConnectedDevice(_ deviceManager: NordicWiFiProvisioner.DeviceManager) {
        print("Connected")
    }
    
    func deviceManagerDidFailToConnect(_ deviceManager: NordicWiFiProvisioner.DeviceManager, error: Error) {
        print("Failed to connect")
    }
    
    func deviceManagerDisconnectedDevice(_ deviceManager: NordicWiFiProvisioner.DeviceManager, error: Error?) {
        print("Disconnected")
    }
    
    func deviceManager(_ deviceManager: NordicWiFiProvisioner.DeviceManager, changedConnectionState newState: NordicWiFiProvisioner.DeviceManager.ConnectionState) {
        switch newState {
        case .disconnected:
            connection = "Disconnected"
        case .connecting:
            connection = "Connecting"
        case .connected:
            connection = "Connected"
        case .disconnecting:
            connection = "Disconnecting"
        }
    }
 }
 ```

### Connect to the device
To connect to the device, call ``DeviceManager/connect()``.

```swift
class ViewModel {
    // Create an instance of DeviceManager.

    func connect() {
        // . . .

        // Connect to the device.
        deviceManager.connect()

        // . . .
    }
}
```
