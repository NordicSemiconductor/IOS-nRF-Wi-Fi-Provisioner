//
//  APWiFiScanView.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Dinesh Harjani on 28/3/24.
//

import SwiftUI
import NordicStyle
import NordicWiFiProvisioner_SoftAP

// MARK: - APWiFiScanView

struct APWiFiScanView: View {
    
    // MARK: Properties
    
    private let scan: APWiFiScan
    private let selected: Bool
    
    // MARK: Init
    
    init(scan: APWiFiScan, selected: Bool) {
        self.scan = scan
        self.selected = selected
    }
    
    // MARK: View
    
    var body: some View {
        HStack {
            Image(systemName: scan.authentication == .open ? "lock.open" : "lock")
            
            Text(scan.ssid)
            
            Text("(\(scan.band.description))")
                .font(.caption)
            
            Spacer()
            
            RSSIView<WiFiRSSI>(rssi: WiFiRSSI(level: scan.rssi))
                .frame(maxWidth: 30, maxHeight: 20)
            
            Image(systemName: "checkmark")
                .isHidden(!selected)
        }
    }
}
