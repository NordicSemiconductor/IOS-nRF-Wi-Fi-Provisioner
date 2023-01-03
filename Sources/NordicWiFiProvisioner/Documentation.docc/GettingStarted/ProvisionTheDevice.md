# Provision the Device

Set the Wi-Fi configuration on the device.

## Overview

You can provision the device with a Wi-Fi network configuration. If the configuration is valid, the device will connect to the network. 

## Set the Wi-Fi Configuration

To set the Wi-Fi configuration, you must provide the instance of ``WifiConfig`` to the ``DeviceManager``. 

```swift
func setConfiguration() {
    do {
        let config = WifiConfig(
            wifi: wifi,
            passphrase: passphrase,
            volatileMemory: false
        )
        try deviceManager.setConfig(config)
    } catch {
        // Handle Error
    }
}
```

Or use the convenience method:

```swift
try deviceManager.setConfig(wifi: wifi, passphrase: passphrase, volatileMemory: false)
```

If the configuration is valid, the device will connect to the network.

## Forget the Wi-Fi Configuration

To forget the Wi-Fi configuration, call ``DeviceManager/forgetConfig()``. The device will forget the configuration and disconnect from the network.

```swift
func forgetConfiguration() {
    do {
        try deviceManager.forgetConfig()
    } catch {
        // Handle Error
    }
}
```

## Provisioning Delegate
To receive the provisioning status, you must implement the ``WiFiProvisionerDelegate`` protocol. The delegate gets the provisioning status updates. It's also notified when the provisioning starts, when it completes, and when it fails.

```swift
extension ViewModel: ProvisionDelegate {
    func deviceManagerDidSetConfig(_ deviceManager: DeviceManager, error: Error?) {

    }
    
    func deviceManager(_ deviceManager: DeviceManager, didChangeState state: ConnectionState) {
        // The device state changed. You can update the UI.
    }
    
    func deviceManagerDidForgetConfig(_ deviceManager: DeviceManager, error: Error?) {

    }
 }
 ```
