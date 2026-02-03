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
    
    private static let DEFAULT_SSID = "nrf-wifiprov"
    
    // MARK: Properties
    
    @State var switchToAccessPoint = true
    @State var ssid = Self.DEFAULT_SSID
    
    // MARK: View
    
    var body: some View {
        VStack {
            List {
                Section("Connection") {
                    Toggle(isOn: $switchToAccessPoint) {
                        Label("Connect Automatically", systemImage: "cpu")
                    }
                    .tint(.universalAccentColor)
                    
                    Text(switchToAccessPoint
                         ? "Disable if you're already connected to the Device you'd like to provision or want to connect manually in Settings."
                         : "Enable to automatically connect to the Device."
                    )
                    .foregroundStyle(.secondary)
                }
                 
                Section("Device Selection") {
                    if switchToAccessPoint {
                        HStack {
                            Label("Device SSID", systemImage: "wifi.circle")
                            
                            TextField("Access Point Name", text: $ssid)
                                .foregroundColor(Color.universalAccentColor)
                                .textInputAutocapitalization(.never)
                                .disableAllAutocorrections()
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.trailing)
                                .submitLabel(.done)
                        }
                    } else {
                        Button("Set up Wi-Fi Connection in Settings") {
                            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                            UIApplication.shared.open(url)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            
            Spacer()
            
            NavigationLink {
                ProvisionOverWiFiView(switchToAccessPoint: switchToAccessPoint, ssidName: ssid)
            } label: {
                Label("Start Provisioning", systemImage: "arrowshape.forward.fill")
                    .frame(maxWidth: .infinity)
            }
            .disabled(switchToAccessPoint && ssid.isEmpty)
            .buttonStyle(.borderedProminent)
            .padding(.horizontal, 16)
            .padding(.vertical)
        }
        .navigationTitle("Provision over Wi-Fi")
        .background(Color.formBackground)
    }
}
