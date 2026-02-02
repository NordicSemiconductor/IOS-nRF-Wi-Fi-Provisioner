//
//  ScanResultRaw.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 13/10/2022.
//

import SwiftUI
import NordicWiFiProvisioner_BLE
import iOS_Common_Libraries

// MARK: - ScanResultRaw

struct ScanResultRaw: View {
    
    // MARK: Private Properties
    
    private let scanResult: ScanResult
    
    // MARK: init
    
    init(scanResult: ScanResult) {
        self.scanResult = scanResult
    }
    
    // MARK: View
    
    var body: some View {
        VStack {
            Label {
                Text(scanResult.name)
                
                if scanResult.provisioned {
                    Image(systemName: "checkmark")
                }
                
                Spacer()
                
                if let version = scanResult.version {
                    Text("v\(version)")
                        .foregroundColor(.secondary)
                }
            } icon: {
                RSSIView(rssi: RSSI(bleLevel: scanResult.rssi))
                    .frame(maxWidth: 20, maxHeight: 18)
            }
            
            if scanResult.connected {
                HStack {
                    Text("Connected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    if scanResult.wifiRSSI != nil {
                        RSSIView(rssi: RSSI(wifiLevel: scanResult.wifiRSSI!))
                            .frame(maxWidth: 16, maxHeight: 12)
                        
                        Text("\(scanResult.wifiRSSI!) dBm")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
            }
        }
    }
}
