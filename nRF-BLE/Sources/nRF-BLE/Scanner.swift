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
    func scanForPeripherals(
        withServices serviceUUIDs: [CBMUUID]?,
        options: [String : Any]? = nil
    ) async throws -> AsyncStream<ScanResult> {
        // TODO: Remove it later
        let serviceUUID = CBMUUID(string: "14387800-130c-49e7-b877-2881c89cb258")
        var iterator = try await centralManager.scanForPeripherals(withServices: [serviceUUID], options: options).makeAsyncIterator()
        
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
    
    open
    func getReady() async throws {
        try await centralManager.waitUntilReady()
    }
}
