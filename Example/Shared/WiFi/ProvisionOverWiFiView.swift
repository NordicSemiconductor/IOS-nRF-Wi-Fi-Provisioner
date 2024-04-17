//
//  ProvisionOverWiFiView.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Dinesh Harjani on 12/2/24.
//

import SwiftUI
import iOS_Common_Libraries
import NordicWiFiProvisioner_SoftAP

// MARK: - ProvisionOverWiFiView

struct ProvisionOverWiFiView: View {
    
    // MARK: Properties
    
    @StateObject var viewModel = ViewModel()
    
    // MARK: View
    
    var body: some View {
        VStack {
            switch viewModel.status {
            case .error(let e):
                NoContentView(title: "Error: \(e.localizedDescription)", systemImage: "exclamationmark.triangle") {
                    AsyncButton("Reconnect") {
                        await viewModel.connect()
                    }
                }
                .foregroundStyle(.red)
            case .notConnected:
                if case let .error(error) = viewModel.status {
                    Label("Error: \(error.localizedDescription)", systemImage: "xmark.octagon")
                        .foregroundStyle(Color.nordicRed)
                        .padding()
                }
                
                NoContentView(title: "Not Connected", systemImage: "point.3.connected.trianglepath.dotted") {
                    AsyncButton("Attempt to Connect") {
                        await viewModel.connect()
                    }
                }
            case .connecting:
                NoContentView(title: "Connecting . . .", systemImage: "point.3.connected.trianglepath.dotted") {
                    ProgressView()
                        .progressViewStyle(.circular)
                }
            case .connected:
                List(selection: $viewModel.selectedScan) {
                    ssidSection()
                    
                    Section("Password") {
                        SecureField("Type Password Here", text: $viewModel.ssidPassword)
                        provisionButton()
                    }
                }
                .task {
                    await viewModel.getScans()
                }
            case .provisioned:
                NoContentView(title: "Provisioned", description: "Provisioning Completed", systemImage: "hand.thumbsup.fill") {
                    AsyncButton("Attempt to Connect") {
                        await viewModel.connect()
                    }
                }
            }
        }
        .navigationTitle("Provision over Wi-Fi")
        .alert(isPresented: $viewModel.showAlert, error: viewModel.alertError) {
            Button("OK", role: .cancel) { 
                // No-op.
            }
        }
    }
    
    @ViewBuilder
    private func ssidSection() -> some View {
        Section("Scanned Networks") {
            ForEach(viewModel.scans) { scan in
                APWiFiScanView(scan: scan, selected: scan == viewModel.selectedScan)
                    .onTapGesture {
                        withAnimation {
                            viewModel.selectedScan = scan
                        }
                    }
            }
            
            AsyncButton("Scan") {
                await viewModel.getScans()
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    private func provisionButton() -> some View {
        AsyncButton(action: {
            await viewModel.provision()
        }, label: {
            Text("Provision")
        })
        .disabled(viewModel.selectedScan == nil)
    }
}

