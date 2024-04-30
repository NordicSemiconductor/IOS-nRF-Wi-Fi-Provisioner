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
                NordicLabel("BLE", image: "bluetooth")
                
                Spacer()
                
                Text(viewModel.peripheralConnectionStatus.isConnected ? "Connected" : "Not Connected")
                    .status(viewModel.peripheralConnectionStatus.status)
            }
            
            HStack {
                NordicLabel("Network", systemImage: "network")
                
                Spacer()
                
                Text(viewModel.provisioned ? "Provisioned" : "Not Provisioned")
                    .status(viewModel.provisionedState)
            }
            
            HStack {
                NordicLabel("Version", systemImage: "wrench.and.screwdriver")
                
                Spacer()
                
                Text(viewModel.version)
                    .foregroundColor(.secondary)
            }
            
            if viewModel.connectionStatus.showStatus {
                HStack {
                    NordicLabel("Wi-Fi Status", systemImage: "wifi")
                    
                    Spacer()
                    
                    Text(viewModel.connectionStatus.status)
                        .status(viewModel.connectionStatus.statusProgressState)
                }
            }
            
            HStack {
                NordicLabel("IP Address", systemImage: "network")
                
                Spacer()
                
                Text(viewModel.connectionStatus.ipAddress)
                    .foregroundColor(.secondary)
            }
            .isHidden(!viewModel.connectionStatus.showIpAddress, remove: true)
        }
    }
}
