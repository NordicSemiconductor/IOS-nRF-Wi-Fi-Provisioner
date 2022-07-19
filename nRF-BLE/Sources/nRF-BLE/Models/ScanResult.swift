//
//  File.swift
//  
//
//  Created by Nick Kibysh on 12/07/2022.
//

import Foundation
import SwiftUI

public
struct ScanResult: Identifiable {
    public let name: String?
    public let id: UUID
    public let rssi: RSSI
    
    /*
    public init(name: String?, id: UUID, rssi: RSSI) {
        self.name = name
        self.id = id
        self.rssi = rssi
    }
     */
}
