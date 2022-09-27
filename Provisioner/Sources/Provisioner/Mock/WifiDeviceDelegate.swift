//
//  File.swift
//  
//
//  Created by Nick Kibysh on 27/09/2022.
//

#if DEBUG
import Foundation
import CoreBluetoothMock

class WifiDeviceDelegate: CBMPeripheralSpecDelegate {

    init() { }

    deinit {
        print("WifiDeviceDelegate deinit")
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveIncludedServiceDiscoveryRequest serviceUUIDs: [CBMUUID]?, for service: CBMServiceMock) -> Swift.Result<(), Error> {
        fatalError("peripheral(_:didReceiveIncludedServiceDiscoveryRequest:for:) has not been implemented")
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveIncludedServiceDiscoveryRequest serviceUUIDs: [CBMUUID]?, for service: CBMService) -> Swift.Result<(), Error> {
        fatalError("peripheral(_:didReceiveIncludedServiceDiscoveryRequest:for:) has not been implemented")
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveDescriptorsDiscoveryRequestFor characteristic: CBMCharacteristicMock) -> Swift.Result<(), Error> {
        fatalError("peripheral(_:didReceiveDescriptorsDiscoveryRequestFor:) has not been implemented")
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveDescriptorsDiscoveryRequestFor characteristic: CBMCharacteristic) -> Swift.Result<(), Error> {
        fatalError("peripheral(_:didReceiveDescriptorsDiscoveryRequestFor:) has not been implemented")
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveReadRequestFor descriptor: CBMDescriptorMock) -> Swift.Result<Data, Error> {
        fatalError("peripheral(_:didReceiveReadRequestFor:) has not been implemented")
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveReadRequestFor descriptor: CBMDescriptor) -> Swift.Result<Data, Error> {
        fatalError("peripheral(_:didReceiveReadRequestFor:) has not been implemented")
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveWriteCommandFor characteristic: CBMCharacteristicMock, data: Data) {
        fatalError("peripheral(_:didReceiveReadRequestFor:) has not been implemented")
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveWriteCommandFor characteristic: CBMCharacteristic, data: Data) {
        fatalError("peripheral(_:didReceiveReadRequestFor:) has not been implemented")
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveWriteRequestFor descriptor: CBMDescriptorMock, data: Data) -> Swift.Result<(), Error> {
        fatalError("peripheral(_:didReceiveWriteRequestFor:data:) has not been implemented")
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveWriteRequestFor descriptor: CBMDescriptor, data: Data) -> Swift.Result<(), Error> {
        fatalError("peripheral(_:didReceiveWriteRequestFor:data:) has not been implemented")
    }

    func peripheralDidReceiveConnectionRequest(_ peripheral: CBMPeripheralSpec) -> Swift.Result<(), Error> {
        return Swift.Result.success(())
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveServiceDiscoveryRequest serviceUUIDs: [CBMUUID]?) -> Swift.Result<(), Error> {
        return Swift.Result.success(())
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveCharacteristicsDiscoveryRequest characteristicUUIDs: [CBMUUID]?, for service: CBMServiceMock) -> Swift.Result<(), Error> {
        return Swift.Result.success(())
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveReadRequestFor characteristic: CBMCharacteristicMock) -> Swift.Result<Data, Error> {
        if characteristic.uuid == .version {
            return versionData
        } else {
            fatalError("peripheral(_:didReceiveReadRequestFor:) has not been implemented")
        }

    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveReadRequestFor characteristic: CBMCharacteristic) -> Swift.Result<Data, Error> {
        fatalError("peripheral(_:didReceiveReadRequestFor:) has not been implemented")
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveWriteRequestFor characteristic: CBMCharacteristicMock, data: Data) -> Swift.Result<(), Error> {
        do {
            let request = try! Request(serializedData: data)
            let command = request.opCode
            switch command {
            case .getStatus:
                peripheral.simulateValueUpdate(wifiStatus, for: .controlPoint)
                return Swift.Result.success(())
            case .startScan:
                peripheral.simulateValueUpdate(wifiStatus, for: .controlPoint)
                let data = try Data(contentsOf: Bundle.module.url(forResource: "MockAP", withExtension: "json")!)
                let aps = try JSONDecoder().decode([Result].self, from: data)
                for ap in aps {
                    peripheral.simulateValueUpdate(try ap.serializedData(), for: .dataOut)
                }
                
                return Swift.Result.success(())
            case .stopScan:
                peripheral.simulateValueUpdate(wifiStatus, for: .controlPoint)
                return Swift.Result.success(())
            default:
                fatalError("OpCode not implemented")
            }
        } catch {
            return Swift.Result.failure(error)
        }
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveWriteRequestFor characteristic: CBMCharacteristic, data: Data) -> Swift.Result<(), Error> {
        fatalError("peripheral(_:didReceiveWriteRequestFor:data:) has not been implemented")
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveSetNotifyRequest enabled: Bool, for characteristic: CBMCharacteristicMock) -> Swift.Result<(), Error> {
        return Swift.Result.success(())
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveSetNotifyRequest enabled: Bool, for characteristic: CBMCharacteristic) -> Swift.Result<(), Error> {
        fatalError("peripheral(_:didReceiveSetNotifyRequest:for:) has not been implemented")
    }
}

extension WifiDeviceDelegate {
    var versionData: Swift.Result<Data, Error> {
        var info = Info()
        info.version = 17
        let data = try! info.serializedData()
        return Swift.Result.success(data)
    }

    var wifiStatus: Data{
        var response = Response()
        response.status = .success
        var deviceStatus = DeviceStatus()
        deviceStatus.state = ConnectionState.connected
        response.deviceStatus = deviceStatus
        return try! response.serializedData()
    }
}

#endif
