//
//  APWiFiScanView.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Dinesh Harjani on 28/3/24.
//

import SwiftUI
import iOS_Common_Libraries
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
        HStack(alignment: .firstTextBaseline) {
            Image(systemName: scan.authentication == .open ? "lock.open" : "lock")
            
            VStack(alignment: .leading) {
                Text(scan.ssid).bold() + Text("  ") + Text("(\(scan.band.description))").font(.caption)
                
                Text("Channel: \(scan.channel)")
                    .font(.callout)
                
                Text("Security: \(scan.authentication.description)")
                    .font(.callout)
            }
            
            Spacer()
            
            RSSIView(rssi: RSSI(wifiLevel: scan.rssi))
                .frame(maxWidth: 30, maxHeight: 20)
            
            Image(systemName: "checkmark")
                .foregroundColor(.nordicBlue)
                .isHidden(!selected)
        }
    }
}
