//
//  AccessPointSection.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Nick Kibysh on 10/11/2022.
//

import SwiftUI
import NordicWiFiProvisioner_BLE

struct AccessPointSection: View {
    
    // MARK: Properties
    
    @EnvironmentObject private var viewModel: DeviceView.ViewModel
    
    // MARK: View
    
    var body: some View {
        Section {
            accessPointSelector
            
            if let wifi = viewModel.wifiNetwork {
                additionalInfo(wifi)
                
                SecureField("Password", text: $viewModel.password)
            }
            
            if viewModel.showVolatileMemory {
                HStack {
                    Text("Volatile Memory")
                    Spacer()
                    Toggle("", isOn: $viewModel.volatileMemory)
                        .toggleStyle(SwitchToggleStyle(tint: .nordicBlue))
                        .accessibilityIdentifier("volatile_memory_toggle")
                }
            }
        } header: {
            Text("Access Point")
        } footer: {
            Text(viewModel.infoFooter)
        }
    }
    
    @ViewBuilder
    var accessPointSelector: some View {
        VStack {
            HStack {
                NordicLabel("Access Point", systemImage: "wifi.circle")
                
                Spacer()
                
                ReversedLabel {
                    Text(viewModel.wifiNetwork?.ssid ?? "Not Selected")
                } image: {
                    Image(systemName: "chevron.forward")
                }
                .foregroundColor(.secondary)
            }
        }
        .accessibilityIdentifier("access_point_selector")
    }
    
    @ViewBuilder
    func additionalInfo(_ wifi: WifiInfo) -> some View {
        VStack {
            DetailRow(title: "Channel", details: "\(wifi.channel)")
            DetailRow(title: "BSSID", details: wifi.bssid.description)
            DetailRow(title: "Band", details: wifi.band?.description ?? "Unknown Band")
            DetailRow(title: "Security", details: wifi.auth?.description ?? "Unknown Security")
        }
    }
}

private struct DetailRow: View {
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
