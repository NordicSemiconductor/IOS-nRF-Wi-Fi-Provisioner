//
//  ProvisionOverWiFiView.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Dinesh Harjani on 12/2/24.
//

import SwiftUI
import NetworkExtension

struct ProvisionOverWiFiView: View {
    
    enum Status {
        case notConnected
        case connected
        case error(_ error: Error)
    }
    
    @State private var status = Status.notConnected
    
    var body: some View {
        switch status {
        case .notConnected:
            Button("Attempt to Connect") {
                let manager = NEHotspotConfigurationManager.shared
                let configuration = NEHotspotConfiguration(ssid: "mobileappsrules")
                manager.apply(configuration) { error in
                    if let error {
                        status = .error(error)
                    } else {
                        status = .connected
                    }
                }
                print("try to connect")
            }
        case .connected:
            Text("Connected to DK")
        case .error(let error):
            Text("Error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ProvisionOverWiFiView()
}
