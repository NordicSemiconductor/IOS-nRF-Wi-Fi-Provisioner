//
//  AccessPointSection.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Nick Kibysh on 10/11/2022.
//

import SwiftUI
import NordicWiFiProvisioner_BLE

// MARK: - AccessPointSection

struct AccessPointSection: View {
    
    // MARK: Properties
    
    let wifi: WifiInfo?
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
                    
                    Text(wifi?.ssid ?? "Not Selected")
                        .foregroundColor(.secondary)
                }
            }
            .accessibilityIdentifier("access_point_selector")
            
            if let wifi {
                additionalInfo(wifi)
                
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
    func additionalInfo(_ wifi: WifiInfo) -> some View {
        VStack {
            DetailView(title: "Channel", details: "\(wifi.channel)")
            DetailView(title: "BSSID", details: wifi.bssid.description)
            DetailView(title: "Band", details: wifi.band?.description ?? "Unknown Band")
            DetailView(title: "Security", details: wifi.auth?.description ?? "Unknown Security")
        }
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
