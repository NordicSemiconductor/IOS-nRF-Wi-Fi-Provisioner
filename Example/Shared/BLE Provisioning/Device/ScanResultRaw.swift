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
    
    init(_ scanResult: ScanResult) {
        self.scanResult = scanResult
    }
    
    // MARK: view
    
    var body: some View {
        LabeledContent {
            VStack(spacing: 4.0) {
                LabeledContent {
                    if scanResult.provisioned {
                        Image(systemName: "checkmark")
                    } else {
                        EmptyView()
                    }
                } label: {
                    Text(scanResult.name)
                }

                if scanResult.connected {
                    LabeledContent {
                        if let wifiRSSI = scanResult.wifiRSSI {
                            HStack {
                                RSSIView(rssi: RSSI(wifiLevel: wifiRSSI))
                                    .frame(maxWidth: 16, maxHeight: 12)
                                
                                Text("\(wifiRSSI) dBm")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        } else {
                            EmptyView()
                        }
                    } label: {
                        Text("Connected")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.leading)
        } label: {
            RSSIView(rssi: RSSI(bleLevel: scanResult.rssi))
                .frame(maxWidth: 20, maxHeight: 18)
        }
    }
}
