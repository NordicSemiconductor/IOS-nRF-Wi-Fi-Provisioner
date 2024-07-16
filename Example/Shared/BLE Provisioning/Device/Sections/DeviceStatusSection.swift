//
//  DeviceStatusSection.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Nick Kibysh on 10/11/2022.
//

import SwiftUI
import NordicWiFiProvisioner_BLE

// MARK: - DeviceStatusSection

struct DeviceStatusSection: View {
    
    // MARK: Environment
    
    @EnvironmentObject private var viewModel: DeviceView.ViewModel
    
    // MARK: View
    
    var body: some View {
        Section("Device Status") {
            HStack {
                Label("Bluetooth LE", image: "bluetooth")
                
                Spacer()
                
                Text(viewModel.peripheralConnectionStatus.description)
                    .status(viewModel.peripheralConnectionStatus.status)
            }
            
            HStack {
                Label("Network", systemImage: "network")
                
                Spacer()
                
                Text(viewModel.provisioned ? "Provisioned" : "Not Provisioned")
                    .status(viewModel.provisionedState)
            }
            
            HStack {
                Label("Version", systemImage: "wrench.and.screwdriver")
                
                Spacer()
                
                Text(viewModel.version)
                    .foregroundColor(.secondary)
            }
            
            if viewModel.connectionStatus.showStatus {
                HStack {
                    Label("Wi-Fi Status", systemImage: "wifi")
                    
                    Spacer()
                    
                    Text(viewModel.connectionStatus.status)
                        .status(viewModel.connectionStatus.statusProgressState)
                }
            }
            
            HStack {
                Label("IP Address", systemImage: "at")
                
                Spacer()
                
                Text(viewModel.connectionStatus.ipAddress)
                    .foregroundColor(.secondary)
            }
            .isHidden(!viewModel.connectionStatus.showIpAddress, remove: true)
        }
    }
}
