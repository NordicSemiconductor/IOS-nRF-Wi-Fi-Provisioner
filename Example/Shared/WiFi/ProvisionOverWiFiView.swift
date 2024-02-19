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
        case connecting
        case connected
        case error(_ error: Error)
    }
    
    @State private var status = Status.notConnected
    @State private var manager = ProvisionManager()
    @State private var led1Enabled = false
    @State private var led2Enabled = false
    @State private var ssids: [String] = []
    @State private var selectedSSID: String?
    @State private var ssidScanning = false
    @State private var ssidPassword: String = ""
    
    var body: some View {
        VStack {
            switch status {
            case .notConnected, .error:
                if case let .error(error) = status {
                    Label("Error: \(error.localizedDescription)", systemImage: "xmark.octagon")
                        .foregroundStyle(.nordicRed)
                        .padding()
                }
                
                Button("Attempt to Connect") {
                    Task { @MainActor in
                        do {
                            status = .connecting
                            try await manager.connect()
                            status = .connected
                        } catch let nsError as NSError {
                            guard nsError.code != 13 else {
                                status = .connected
                                return
                            }
                            status = .error(nsError)
                        } catch {
                            status = .error(error)
                        }
                    }
                }
            case .connecting:
                ProgressView()
                    .progressViewStyle(.circular)
                
                Text("Connecting...")
            case .connected:
                List(selection: $selectedSSID) {
                    Section("LED Testing") {
                        Button {
                            Task { @MainActor in
                                switch await manager.setLED(ledNumber: 1, enabled: !led1Enabled) {
                                case .success:
                                    led1Enabled.toggle()
                                case .failure(let error):
                                    status = .error(error)
                                }
                            }
                        } label: {
                            Label("LED 1", systemImage: led1Enabled ? "lamp.table.fill" : "lamp.table")
                        }
                        
                        Button {
                            Task { @MainActor in
                                switch await manager.setLED(ledNumber: 2, enabled: !led2Enabled) {
                                case .success:
                                    led2Enabled.toggle()
                                case .failure(let error):
                                    status = .error(error)
                                }
                            }
                        } label: {
                            Label("LED 2", systemImage: led2Enabled ? "lamp.table.fill" : "lamp.table")
                        }
                    }
                    
                    Section("SSID") {
                        ForEach(ssids, id: \.self) { ssid in
                            Button(ssid) {
                                selectedSSID = ssid
                            }
                            .tag(ssid)
                        }
                        
                        Button {
                            Task { @MainActor in
                                self.ssidScanning = true
                                self.ssids = try await manager.getSSIDs()
                                self.ssidScanning = false
                            }
                        } label: {
                            if ssidScanning {
                                ProgressView()
                                    .progressViewStyle(.circular)
                            } else {
                                Text("Scan")
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    Section("Password") {
                        SecureField("Type Password Here", text: $ssidPassword)
                    }
                }
                .task {
                    Task {
                        switch await manager.ledStatus(ledNumber: 1) {
                        case .success(let result):
                            led1Enabled = result
                        case .failure(let error):
                            status = .error(error)
                        }
                        
                        switch await manager.ledStatus(ledNumber: 2) {
                        case .success(let result):
                            led2Enabled = result
                        case .failure(let error):
                            status = .error(error)
                        }
                    }
                }
            }
        }
        .navigationTitle("Provision over Wi-Fi")
    }
}

#Preview {
    ProvisionOverWiFiView()
}
