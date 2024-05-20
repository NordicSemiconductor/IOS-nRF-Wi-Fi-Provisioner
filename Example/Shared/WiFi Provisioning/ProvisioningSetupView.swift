//
//  ProvisioningSetupView.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Dinesh Harjani on 6/5/24.
//

import SwiftUI
import iOS_Common_Libraries

// MARK: - ProvisioningSetupView

struct ProvisioningSetupView: View {
    
    // MARK: Properties
    
    @Binding var switchToAccessPoint: Bool
    @Binding var ssid: String
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
