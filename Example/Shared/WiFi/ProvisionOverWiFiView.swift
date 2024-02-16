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
        ZStack {
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
                    Section("LED Testing") {
                        Button {
                            Task {
                                switch try await manager.setLED(ledNumber: 1, enabled: !led1Enabled) {
                                case .success:
                                    led1Enabled.toggle()
                                default:
                                    break
                                }
                            }
                        } label: {
                            Label("LED 1", systemImage: led1Enabled ? "lamp.table.fill" : "lamp.table")
                        }
                        
                        Button {
                            Task {
                                switch try await manager.setLED(ledNumber: 2, enabled: !led2Enabled) {
                                case .success:
                                    led2Enabled.toggle()
                                default:
                                    break
                                }
                            }
                        } label: {
                            Label("LED 2", systemImage: led2Enabled ? "lamp.table.fill" : "lamp.table")
                        }
                    }
                    
                    Section("Wi-Fi Scanning") {
                        ForEach(ssids, id: \.self) { ssid in
                            NavigationLink {
                                Text(ssid)
                                    .navigationTitle(Text(ssid))
                            } label: {
                                Text(ssid)
                            }
                        }
                        Button("Read SSID") {
                            Task {
                                self.ssids = try await manager.getSSIDs()
                            }
                        }
                    }
                }
                .task {
                    Task {
                        do {
                            led1Enabled = try await manager.ledStatus(ledNumber: 1)
                            led2Enabled = try await manager.ledStatus(ledNumber: 2)
                        } catch let e {
                            print(e.localizedDescription)
                        }
                    }
                }
            case .error(let error):
                Text("Error: \(error.localizedDescription)")
            }
        }
        .navigationTitle("Provision over Wi-Fi")
    }
}

#Preview {
    ProvisionOverWiFiView()
}
