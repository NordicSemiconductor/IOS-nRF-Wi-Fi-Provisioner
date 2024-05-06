//
//  ProvisioningConfiguration.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Dinesh Harjani on 6/5/24.
//

import SwiftUI

// MARK: - ProvisioningConfiguration

struct ProvisioningConfiguration: View {
    
    @Binding var switchToAccessPoint: Bool
    @Binding var ssid: String
    
    var body: some View {
        List {
            Section("Provisioning Configuration") {
                HStack {
                    NordicLabel("Switch to Access Point", systemImage: "wifi.circle")
                    
                    Spacer()
                    
                    Toggle("", isOn: $switchToAccessPoint)
                        .tint(.accentColor)
                }
                
                Text("""
                If you're already connected to the Device you'd like to provision, or would rather do it manually, you may disable this.
                """)
                .font(.caption)
                
                Button("Open Settings") {
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(url)
                }
            }
            
            if switchToAccessPoint {
                Section {
                    HStack {
                        NordicLabel("SSID", systemImage: "wifi.circle")
                        
                        Spacer()
                            .frame(maxWidth: .infinity)
                        
                        TextField("Access Point Name", text: $ssid)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Section("Verification") {
                HStack {
                    NordicLabel("Enable Post-Provisioning Verification", systemImage: "wifi.circle")
                    
                    Spacer()
                    
                    Toggle("", isOn: $switchToAccessPoint)
                        .tint(.accentColor)
                }
                
                Text("""
                If Enabled, after successful provisioning we will switch to the network you've provisioned your Device to, and try to find it in that network.
                
                Note that this adds a couple of extra steps involving Network Configuration changes on your iPhone that might throw errors, but your Device might've still been successfully provisioned.
                """)
                .font(.caption)
            }
        }
        
        Spacer()
        
        Button("Start") {
            
        }
    }
}
