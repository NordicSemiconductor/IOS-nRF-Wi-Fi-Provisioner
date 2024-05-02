//
//  AccessPointSection.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Nick Kibysh on 10/11/2022.
//

import SwiftUI
import NordicWiFiProvisioner_BLE
import NordicWiFiProvisioner_SoftAP

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
            VStack {
                HStack {
                    NordicLabel("Access Point", systemImage: "wifi.circle")
                    
                    Spacer()
                    
                    Text(accessPoint?.ssid ?? "Not Selected")
                        .foregroundColor(.secondary)
                }
            }
            .accessibilityIdentifier("access_point_selector")
            
            if let accessPoint {
                additionalInfo(accessPoint)
                
                SecureField("Password", text: $password)
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
    
    @ViewBuilder
    func additionalInfo(_ accessPoint: AccessPointInfo) -> some View {
        VStack {
            DetailView(title: "Channel", details: accessPoint.channel)
            DetailView(title: "BSSID", details: accessPoint.bssid)
            DetailView(title: "Band", details: accessPoint.band)
            DetailView(title: "Security", details: accessPoint.security)
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

// MARK: - DetailView

private struct DetailView: View {
    
    let title: String
    let details: String
    
    var body: some View {
        HStack {
            ReversedLabel {
                Text(title)
                    .font(.caption)
            } image: {
                EmptyView()
            }

            Spacer()
            Text(details)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxHeight: 12)
    }
}
