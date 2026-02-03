//
//  AccessPointSection.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Nick Kibysh on 10/11/2022.
//

import SwiftUI
import NordicWiFiProvisioner_BLE
import NordicWiFiProvisioner_SoftAP
import iOS_Common_Libraries

// MARK: AccessPointSection

struct AccessPointSection: View {
    
    // MARK: Properties
    
    let accessPoint: AccessPointInfo?
    @Binding var password: String
    let showVolatileMemory: Bool
    @Binding var volatileMemory: Bool
    let footer: String
    
    // MARK: View
    
    var body: some View {
        Section {
            LabeledContent {
                Text(accessPoint?.ssid ?? "Not Selected")
            } label: {
                Label("SSID", systemImage: "wifi.circle")
            }
            .accessibilityIdentifier("access_point_selector")
            
            if let accessPoint {
                accessPoint
                
                HStack {
                    Label("Password", systemImage: "key.horizontal")
                    
                    PasswordField(binding: $password, enabled: true)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.trailing)
                        .submitLabel(.done)
                        .buttonStyle(.plain)
                }
            }
            
            if showVolatileMemory {
                HStack {
                    Text("Volatile Memory")
                    
                    Spacer()
                    
                    Toggle("", isOn: $volatileMemory)
                        .toggleStyle(SwitchToggleStyle(tint: .nordicBlue))
                        .accessibilityIdentifier("volatile_memory_toggle")
                }
            }
        } header: {
            Text("Access Point")
        } footer: {
            Text(footer)
        }
    }
}

// MARK: - AccessPointInfo

struct AccessPointInfo {
    
    let ssid: String
    let bssid: String
    let channel: String
    let band: String
    let security: String
}

extension AccessPointInfo: View {
    
    var body: some View {
        LabeledContent("Channel", value: channel)
        
        LabeledContent("BSSID", value: bssid)
        
        LabeledContent("Band", value: band)
        
        LabeledContent("Security", value: security)
    }
}

extension WifiInfo {
    
    func accessPoint() -> AccessPointInfo {
        AccessPointInfo(ssid: self.ssid, bssid: self.bssid.description, channel: "\(self.channel)", band: self.band?.description ?? "Unknown Band", security: self.auth?.description ?? "Unknown Security")
    }
}

extension APWiFiScan {
    
    func accessPoint() -> AccessPointInfo {
        AccessPointInfo(ssid: ssid, bssid: bssidString(), channel: "\(channel)", band: band.description, security: authentication.description)
    }
}
