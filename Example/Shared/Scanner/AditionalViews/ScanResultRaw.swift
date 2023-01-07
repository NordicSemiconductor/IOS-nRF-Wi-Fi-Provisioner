//
//  ScanResultRaw.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 13/10/2022.
//

import SwiftUI
import NordicWiFiProvisioner
import NordicStyle

struct ScanResultRaw: View {
    let scanResult: ScanResult
    
    var body: some View {
        VStack {
            HStack {
                RSSIView(rssi: BluetoothRSSI(level: scanResult.rssi))
                    .frame(maxWidth: 20, maxHeight: 18)
                Text(scanResult.name)
                if scanResult.provisioned {
                    Image(systemName: "checkmark")
                }
                Spacer()
                if scanResult.version != nil {
                    Text("v\(scanResult.version!)")
                        .foregroundColor(.secondary)
                }
            }
            if scanResult.connected {
                HStack {
                    Text("Connected")
                        .font(.caption)
                    .foregroundColor(.secondary)
                    Spacer()
                    if scanResult.wifiRSSI != nil {
                        RSSIView(rssi: WiFiRSSI(level: scanResult.wifiRSSI!))
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
