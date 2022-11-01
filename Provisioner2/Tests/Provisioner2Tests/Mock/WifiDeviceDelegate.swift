//
//  File.swift
//  
//
//  Created by Nick Kibysh on 27/09/2022.
//

import Foundation
import CoreBluetoothMock
import os

@testable import Provisioner2

class WifiDeviceDelegate: CBMPeripheralSpecDelegate {
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
            fatalError("peripheral(_:didReceiveReadRequestFor: \(characteristic) has not been implemented")
        }
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveWriteRequestFor characteristic: CBMCharacteristicMock, data: Data) -> Swift.Result<(), Error> {
        do {
            let request = try! Proto.Request(serializedData: data)
            let command = request.opCode
            switch command {
            case .getStatus:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    peripheral.simulateValueUpdate(self.wifiStatus(.disconnected), for: .controlPoint)
                }
                return Swift.Result.success(())
            case .startScan:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    peripheral.simulateValueUpdate(self.wifiStatus(.disconnected), for: .controlPoint)
                }
                let data = try Data(contentsOf: Bundle.module.url(forResource: "MockAP", withExtension: "json")!)
                let aps = try JSONDecoder().decode([Proto.Result].self, from: data)
                
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                    var iterator = aps.makeIterator()
                    while let next = iterator.next() {
                        DispatchQueue.main.async {
                            peripheral.simulateValueUpdate(try! next.serializedData(), for: .dataOut)
                        }
                        sleep(100)
                    }
                }
                
                return Swift.Result.success(())
            case .stopScan:
                peripheral.simulateValueUpdate(wifiStatus(.connected), for: .controlPoint)
                return Swift.Result.success(())
            case .setConfig:
                peripheral.simulateValueUpdate(wifiStatus(.disconnected), for: .controlPoint)
                
                let states = Proto.ConnectionState.allCases
                
                DispatchQueue.global().async {
                    var iterator = states.makeIterator()
                    while let next = iterator.next() {
                        DispatchQueue.main.async {
                            peripheral.simulateValueUpdate(
                                try! self.connectionStatusResult(next).serializedData(),
                                for: .dataOut
                            )
                        }
                        sleep(1000)
                    }
                }
                
                return Swift.Result.success(())
            default:
                fatalError("OpCode not implemented")
            }
        } catch {
            return Swift.Result.failure(error)
        }
    }

    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveSetNotifyRequest enabled: Bool, for characteristic: CBMCharacteristicMock) -> Swift.Result<(), Error> {
        return Swift.Result.success(())
    }
    
    var versionData: Swift.Result<Data, Error> {
        var info = Proto.Info()
        info.version = 17
        let data = try! info.serializedData()
        return Swift.Result.success(data)
    }

    func wifiStatus(_ stt: Proto.ConnectionState) -> Data {
        var response = Proto.Response()
        response.status = .success
        response.requestOpCode = .getStatus
        var deviceStatus = Proto.DeviceStatus()
        
        deviceStatus.state = stt
        deviceStatus.provisioningInfo = wifiInfo()

        response.deviceStatus = deviceStatus

        return try! response.serializedData()
    }

    func connectionStatusResult(_ stt: Proto.ConnectionState) -> Proto.Result {
        var result = Proto.Result()
        result.state = stt
        return result
    }

    func wifiInfo() -> Proto.WifiInfo {
        var wfInfo = Proto.WifiInfo()
        wfInfo.ssid = "Nordic Guest".data(using: .utf8)!
        wfInfo.bssid = 0xFA_23_1A_2B_3D_0A.toData()
        wfInfo.channel = 6
        wfInfo.auth = .wpa2Psk
        wfInfo.band = .band5Gh
        return wfInfo
    }
}

extension Int {
    func toData() -> Data {
        var value = self
        return Data(bytes: &value, count: MemoryLayout.size(ofValue: value))
    }
}

class NotConnoctableWiFiDelegate: WifiDeviceDelegate {
    override func peripheralDidReceiveConnectionRequest(_ peripheral: CBMPeripheralSpec) -> Swift.Result<(), Error> {
        return .failure(NSError(domain: "NotConnoctableWiFiDelegate", code: 1))
    }
}

class NoServicesWiFiDelegate: WifiDeviceDelegate {
    override func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveServiceDiscoveryRequest serviceUUIDs: [CBMUUID]?) -> Swift.Result<(), Error> {
        return .failure(NSError(domain: "NoServicesWiFiDelegate", code: 2))
    }
}
