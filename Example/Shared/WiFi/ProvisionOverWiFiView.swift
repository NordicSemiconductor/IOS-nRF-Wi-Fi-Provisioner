//
//  ProvisionOverWiFiView.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Dinesh Harjani on 12/2/24.
//

import SwiftUI
import NordicWiFiProvisioner_SoftAP

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
                Task {
                    do {
                        try await ProvisionManager().connect()
                    } catch let e {
                        print(e.localizedDescription)
                    }
                }
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
