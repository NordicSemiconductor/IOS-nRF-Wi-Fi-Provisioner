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
    @State private var manager = ProvisionManager()
    @State private var led1Enabled = false
    @State private var led2Enabled = false
    @State private var ssids: [String] = []
    
    var body: some View {
        switch status {
        case .notConnected:
            Button("Attempt to Connect") {
                Task {
                    do {
                        try await manager.connect()
                        status = .connected
                    } catch let e as NSError {
                        if e.code == 13 {
                            status = .connected
                        }
                    }
                }
            }
        case .connected:
            List {
                ForEach(ssids, id: \.self) {
                    Text($0)
                }
                Button("Read SSID") {
                    Task {
                        self .ssids = try await manager.getSSIDs()
                    }
                }
            }
            /*
            VStack {
                Button("Set LED 1") {
                    Task {
                        do {
                            try await manager.setLED(ledNumber: 1, enabled: led1Enabled)
                            led1Enabled.toggle()
                        } catch let e {
                            print(e.localizedDescription)
                        }
                    }
                }
                Button("Set LED 2") {
                    Task {
                        do {
                            try await manager.setLED(ledNumber: 2, enabled: led2Enabled)
                            led2Enabled.toggle()
                        }
                    }
                }
            }
             */
        case .error(let error):
            Text("Error: \(error.localizedDescription)")
        }
    }
}

#Preview {
    ProvisionOverWiFiView()
}
