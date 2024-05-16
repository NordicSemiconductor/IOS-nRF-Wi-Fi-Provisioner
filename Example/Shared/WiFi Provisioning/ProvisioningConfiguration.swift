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
    
    // MARK: Properties
    
    @Binding var switchToAccessPoint: Bool
    @Binding var ssid: String
    @Binding var verifyProvisioning: Bool
    let onStart: () -> Void
    
    // MARK: View
    
    var body: some View {
        List {
            Section("Device Selection") {
                Toggle(isOn: $switchToAccessPoint) {
                    Label("Connect Automatically", systemImage: "cpu")
                }
                .tint(.accentColor)
                
                if switchToAccessPoint {
                    HStack {
                        Label("Device SSID", systemImage: "wifi.circle")
                        
                        TextField("Access Point Name", text: $ssid)
                            .frame(maxWidth: .infinity)
                            .multilineTextAlignment(.trailing)
                            .submitLabel(.done)
                    }
                    
                    Label("Disable if you're already connected to the Device you'd like to provision or want to connect manually in Settings.", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                } else {
                    Label("Enable to automatically connect to the Device.", systemImage: "info.square.fill")
                        .font(.caption)
                    
                    Button("Set up Wi-Fi Connection in Settings") {
                        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                        UIApplication.shared.open(url)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
            Section("Verification") {
                Toggle(isOn: $verifyProvisioning) {
                    Label("Post-Provisioning Verification", systemImage: "flag.checkered")
                }
                .tint(.accentColor)
                
                Label("Enable to switch to the network you've provisioned your Device to, and try to find it in that network.", systemImage: "info.square.fill")
                .font(.caption)
                
                Label("This adds a couple of extra steps involving Network Configuration changes on your iPhone that might throw errors, but your Device might've still been successfully provisioned.", systemImage: "exclamationmark.triangle.fill")
                .font(.caption)
            }
        }
        
        Spacer()
        
        Button(action: onStart) {
            Label("Start Provisioning", systemImage: "arrowshape.forward.fill")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .padding(.horizontal, 16)
        .padding(.vertical)
    }
}
