# ``NordicWiFiProvisioner/DeviceManager``

### Initializing a Device Manager

- ``init(scanResult:)``
- ``init(deviceId:)``
- ``deviceId``

### Establishing or Canceling Connections with nRF-Device

Before doing any other operation, you have to connect to the device. You can do it by calling ``connect()`` method. The connection is asynchronous, so you have to implement ``ConnectionDelegate`` to get the connection status.

- ``connect()``
- ``disconnect()``
- ``ConnectionState-swift.enum``
- ``connectionState-swift.property``
- ``connectionDelegate``

### Read the information

You can read the device information like version or provisioned WiFi network by calling ``readVersion()`` and ``readDeviceStatus()``. The result is returned asynchronously, so you have to implement ``InfoDelegate`` to get the result.

- ``readVersion()``
- ``readDeviceStatus()``
- ``infoDelegate``

### Scanning or Stopping Scans of WiFi networks

- ``startScan(scanParams:)``
- ``startScan(band:passive:period:groupChannels:)``
- ``stopScan()``
- ``wiFiScanerDelegate``

### Provision the device with a WiFi network

- ``setConfig(_:)``
- ``setConfig(wifi:passphrase:volatileMemory:)``
- ``forgetConfig()``
- ``provisionerDelegate``
