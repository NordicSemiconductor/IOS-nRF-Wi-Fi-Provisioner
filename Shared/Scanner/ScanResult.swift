//
//  ScanResult.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 12/07/2022.
//

import Foundation

struct ScanResult: Identifiable, Hashable {
    let name: String
    let id: UUID
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
