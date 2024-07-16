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
    
    // MARK: Init
    
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

// MARK: - Preview

#if DEBUG
struct ScanResultRaw_Previews: PreviewProvider {
    struct MockScanResult  {
        static let unprov = ScanResult(id: UUID(), name: "Unprovisioned Device", rssi: -58, provisioned: false, connected: false)
        static let provUnconnected = ScanResult(id: UUID(), name: "Provisioned Unconnected", rssi: -68, provisioned: true, connected: false)
        static let provConnected = ScanResult(id: UUID(), name: "Provisioned Connected", rssi: -88, provisioned: true, connected: true, wifiRSSI: -48)
    }
    
    static var previews: some View {
        List {
            Section("Preview") {
                ScanResultRaw(scanResult: MockScanResult.unprov)
                ScanResultRaw(scanResult: MockScanResult.provUnconnected)
                ScanResultRaw(scanResult: MockScanResult.provConnected)
            }
        }
    }
}
#endif
