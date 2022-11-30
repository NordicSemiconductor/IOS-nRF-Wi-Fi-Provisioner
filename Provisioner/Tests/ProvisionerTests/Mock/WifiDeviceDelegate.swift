//
//  File.swift
//  
//
//  Created by Nick Kibysh on 27/09/2022.
//

import Foundation
import CoreBluetoothMock
import os

@testable import Provisioner

class WifiDeviceDelegate: CBMPeripheralSpecDelegate {
    let scanResultQueue = OperationQueue()
    
    init() {
        scanResultQueue.maxConcurrentOperationCount = 1
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
            fatalError("peripheral(_:didReceiveReadRequestFor: \(characteristic) has not been implemented")
        }
    }
    
    func peripheral(_ peripheral: CBMPeripheralSpec, didReceiveWriteRequestFor characteristic: CBMCharacteristicMock, data: Data) -> Swift.Result<(), Error> {
        do {
            let request = try Proto.Request(serializedData: data)
            let command = request.opCode
            switch command {
            case .getStatus:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    let response = self.response(
                        deviceStatus: self.deviceStatus(
                            status: .connected,
                            connectionInfo: self.connectionInfo(ipAddress: .ip1),
                            provisioningInfo: WifiInfo.wifi1.proto,
                            scanInfo: ScanParams.sp1.proto
                        ),
                        status: .success, requestCode: .getStatus)
                    peripheral.simulateValueUpdate(response, for: .controlPoint)
                }
                return Swift.Result.success(())
            case .startScan:
                return try startScan(peripheral)
            case .stopScan:
                return try stopScan(peripheral)
            case .setConfig:
                let response = self.response(status: .success, requestCode: .setConfig)
                peripheral.simulateValueUpdate(response, for: .controlPoint)
                
                let states = Proto.ConnectionState.allCases.dropLast(1)
                let connectionReasons = Proto.ConnectionFailureReason.allCases
                
                DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
                    var iterator = states.makeIterator()
                    while let next = iterator.next() {
                        DispatchQueue.main.async {
                            peripheral.simulateValueUpdate(
                                try! self.connectionStatusResult(next).serializedData(),
                                for: .dataOut
                            )
                        }
                        sleep(1)
                    }
                    
                    for r in connectionReasons {
                        DispatchQueue.main.async {
                            peripheral.simulateValueUpdate(
                                try! self.connectionStatusResult(.connectionFailed, reason: r).serializedData(),
                                for: .dataOut
                            )
                        }
                        sleep(1)
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
    
    func response(deviceStatus: Proto.DeviceStatus? = nil, status: Proto.Status? = .success, requestCode: Proto.OpCode) -> Data {
        var response = Proto.Response()
        if let status {
            response.status = status
        }

        response.requestOpCode = requestCode

        if let deviceStatus {
            response.deviceStatus = deviceStatus
        }
        
        return try! response.serializedData()
    }
    
    func scanInfo() -> Proto.ScanParams {
        return ScanParams.sp1.proto
    }
    
    func connectionStatusResult(_ stt: Proto.ConnectionState, reason: Proto.ConnectionFailureReason? = nil) -> Proto.Result {
        var result = Proto.Result()
        result.state = stt
        
        if let reason {
            result.reason = reason
        }
        
        return result
    }
    
    func wifiInfo() -> Proto.WifiInfo {
        return WifiInfo.wifi1.proto
    }

    func deviceStatus(status: Proto.ConnectionState?, connectionInfo: Proto.ConnectionInfo?, provisioningInfo: Proto.WifiInfo?, scanInfo: Proto.ScanParams?) -> Proto.DeviceStatus {
        var deviceStatus = Proto.DeviceStatus()
        if let status {
            deviceStatus.state = status
        }
        if let connectionInfo {
            deviceStatus.connectionInfo = connectionInfo
        }
        if let provisioningInfo {
            deviceStatus.provisioningInfo = provisioningInfo
        }
        if let scanInfo {
            deviceStatus.scanInfo = scanInfo
        }

        return deviceStatus
    }

    func connectionInfo(ipAddress: IPAddress) -> Proto.ConnectionInfo {
        var connectionInfo = ConnectionInfo()
        connectionInfo.ip = ipAddress
        return connectionInfo.proto
    }

    func accessPoints() throws -> [Proto.Result] {
        let data = try Data(contentsOf: Bundle.module.url(forResource: "MockAP", withExtension: "json")!)
        return try JSONDecoder().decode([Proto.Result].self, from: data)
    }
    
    func startScan(_ peripheral: CBMPeripheralSpec) throws -> Swift.Result<Void, Error> {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let response = self.response(status: .success, requestCode: .startScan)
            peripheral.simulateValueUpdate(response, for: .controlPoint)
        }
        
        let aps = try accessPoints()
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            for sr in aps {
                peripheral.simulateValueUpdate(try! sr.serializedData(), for: .dataOut)
            }
        }
    
        return Swift.Result.success(())
    }
    
    func stopScan(_ peripheral: CBMPeripheralSpec) throws -> Swift.Result<Void, Error> {
        let response = self.response(status: .success, requestCode: .stopScan)
        peripheral.simulateValueUpdate(response, for: .controlPoint)
        return Swift.Result.success(())
    }
}

extension Int {
    func toData() -> Data {
        var value = self
        let data = Data(bytes: &value, count: MemoryLayout.size(ofValue: value))
        let arr = [UInt8](data)
        return Data(arr.reversed())
    }
}
