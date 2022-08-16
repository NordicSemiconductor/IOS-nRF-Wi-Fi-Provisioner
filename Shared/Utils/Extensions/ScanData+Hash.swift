//
//  ScanData+Hash.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 11/08/2022.
//

import Foundation
import AsyncBluetooth
import CoreBluetooth

extension ScanData: Hashable {
    public static func == (lhs: ScanData, rhs: ScanData) -> Bool {
        lhs.peripheral.identifier == rhs.peripheral.identifier
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.peripheral.identifier)
    }
}

extension ScanData {
    func containsService(_ serviceId: UUID) -> Bool {
        self.peripheral.discoveredServices?.contains(where: { $0.uuid == CBUUID(nsuuid: serviceId) }) ?? false 
    }
}
