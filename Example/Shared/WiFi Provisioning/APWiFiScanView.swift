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
    
    private let isOpenNetwork: Bool
    private let ssid: String
    private let band: String
    private let channel: String
    private let security: String
    private let rssi: RSSI
    private let isSelected: Bool
    
    // MARK: Init
    
    init(scan: APWiFiScan, selected: Bool) {
        self.isOpenNetwork = scan.authentication == .open
        self.ssid = scan.ssid
        self.band = scan.band.description
        self.channel = "\(scan.channel)"
        self.security = scan.authentication.description
        self.rssi = RSSI(wifiLevel: scan.rssi)
        self.isSelected = selected
    }
    
    init(wiFiScan: WifiScanResult, selected: Bool) {
        self.isOpenNetwork = wiFiScan.wifi.isOpen
        self.ssid = wiFiScan.wifi.ssid
        self.band = wiFiScan.wifi.band?.description ?? "Unknown Band"
        self.channel = "\(wiFiScan.wifi.channel)"
        self.security = wiFiScan.wifi.auth?.description ?? "Unknown Security"
        if let rssi = wiFiScan.rssi {
            self.rssi = RSSI(wifiLevel: rssi)
        } else {
            self.rssi = RSSI.outOfRange
        }
        self.isSelected = selected
    }
    
    // MARK: View
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Label {
                VStack(alignment: .leading) {
                    Text(ssid + " ").bold() + Text(band).bold().font(.caption)
                    
                    Text("Channel: \(channel)")
                        .foregroundStyle(Color.secondarylabel)
                        .font(.callout)
                    
                    Text("Security: \(security)")
                        .foregroundStyle(Color.secondarylabel)
                        .font(.callout)
                }
            } icon: {
                Image(systemName: isOpenNetwork ? "lock.open" : "lock")
            }
            
            Spacer()
            
            RSSIView(rssi: rssi)
                .frame(maxWidth: 30, maxHeight: 20)
            
            Image(systemName: "checkmark")
                .foregroundColor(.nordicBlue)
                .isHidden(!isSelected)
        }
    }
}
