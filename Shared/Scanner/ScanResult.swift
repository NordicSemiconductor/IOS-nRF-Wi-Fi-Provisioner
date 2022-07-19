//
//  ScanResult.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 12/07/2022.
//

import Foundation
import nRF_BLE

struct ScanResult: Identifiable, Hashable {
    let name: String
    let id: UUID
    let rssi: RSSI
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ScanResult, rhs: ScanResult) -> Bool {
        lhs.id == rhs.id
    }
}
