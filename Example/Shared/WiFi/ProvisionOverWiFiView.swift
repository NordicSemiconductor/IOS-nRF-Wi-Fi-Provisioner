//
//  ProvisionOverWiFiView.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Dinesh Harjani on 12/2/24.
//

import SwiftUI

struct ProvisionOverWiFiView: View {
    
    enum Status {
        case notConnected
        case connected
    }
    
    @State private var status = Status.notConnected
    
    var body: some View {
        switch status {
        case .notConnected:
            Button("Attempt to Connect") {
                print("try to connect")
            }
        case .connected:
            Text("Connected to DK")
        }
    }
}

#Preview {
    ProvisionOverWiFiView()
}
