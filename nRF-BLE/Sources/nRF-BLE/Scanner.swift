//
//  File.swift
//  
//
//  Created by Nick Kibysh on 06/07/2022.
//

import Foundation
import AsyncBluetooth
import CoreBluetoothMock
//import CoreBluetooth
import Combine

open
class Scanner {
    private let centralManager: CentralManager
    
    public
    init() {
        self.centralManager = CentralManager()
    }
    
    open 
    var isScanning: Bool {
        return centralManager.isScanning
    }
    
    open
    func scanForPeripherals(
        withServices serviceUUIDs: [UUID]?,
        options: [String : Any]? = nil,
        onlyConnectable: Bool = true
    ) async throws -> AsyncStream<ScanResult> {
        var iterator = try await centralManager.scanForPeripherals(
            withServices: serviceUUIDs.map { $0.map { CBMUUID(nsuuid: $0) } },
            options: options
        ).makeAsyncIterator()
        
        return AsyncStream<ScanResult> {
            do {
                if let scanData = await iterator.next() {
                    return ScanResult(
                        name: scanData.peripheral.name ?? scanData.advertisementData[CBMAdvertisementDataLocalNameKey] as? String,
                        id: scanData.peripheral.identifier,
                        rssi: RSSI(level: scanData.rssi.intValue)
                    )
                }
            }
            
            return nil
        }
    }
    
    open func stopScan() async {
        await centralManager.stopScan()
    }
    
    open
    func getReady() async throws {
        try await centralManager.waitUntilReady()
    }
}
