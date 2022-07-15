//
//  File.swift
//  
//
//  Created by Nick Kibysh on 06/07/2022.
//

import Foundation
import AsyncBluetooth
import CoreBluetoothMock
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
        var iterator = try await centralManager.scanForPeripherals(withServices: serviceUUIDs, options: options).makeAsyncIterator()
        
        return AsyncStream<ScanResult> {
            do {
                if let scanData = await iterator.next() {
                    return ScanResult(name: scanData.advertisementData[CBMAdvertisementDataLocalNameKey] as? String, id: scanData.peripheral.identifier)
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
