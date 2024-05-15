//
//  ProvisioningConfiguration.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Dinesh Harjani on 6/5/24.
//

import SwiftUI
import iOS_Common_Libraries

// MARK: - ProvisioningConfiguration

struct ProvisioningConfiguration: View {
    
    @Binding var switchToAccessPoint: Bool
    @Binding var ssid: String
    @Binding var verifyProvisioning: Bool
    let onStart: () -> Void
    
    var body: some View {
        List {
            Section("Provisioning Configuration") {
                Toggle(isOn: $switchToAccessPoint) {
                    Label("Connect to Device", systemImage: "cpu")
                }
                .tint(.accentColor)
                
                if switchToAccessPoint {
                    HStack {
                        Label("SSID", systemImage: "wifi.circle")
                        
                        Spacer()
                            .frame(maxWidth: .infinity)
                        
                        TextField("Access Point Name", text: $ssid)
                            .multilineTextAlignment(.trailing)
                            .submitLabel(.done)
                    }
                    
                    Text("Disable if you're already connected to the device you'd like to provision.")
                        .font(.caption)
                }
                
                if !switchToAccessPoint {
                    Text("Enable to automatically connect to the Device (SoftAP)")
                        .font(.caption)
                    
                    Button("Connect Manually in Settings") {
                        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                        UIApplication.shared.open(url)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
            Section("Verification") {
                Toggle(isOn: $verifyProvisioning) {
                    Label("Enable Post-Provisioning Verification", systemImage: "flag.checkered")
                }
                .tint(.accentColor)
                
                Text("""
                Enable to switch to the network you've provisioned your Device to, and try to find it in that network.
                
                Note that this adds a couple of extra steps involving Network Configuration changes on your iPhone that might throw errors, but your Device might've still been successfully provisioned.
                """)
                .font(.caption)
            }
        }
        
        Spacer()
        
        Button("Start", action: onStart)
            .buttonStyle(.borderedProminent)
    }
}
