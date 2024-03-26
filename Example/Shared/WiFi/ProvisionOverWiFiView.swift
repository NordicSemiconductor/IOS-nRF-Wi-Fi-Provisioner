//
//  ProvisionOverWiFiView.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Dinesh Harjani on 12/2/24.
//

import SwiftUI
import NordicStyle

struct ProvisionOverWiFiView: View {
    
    @StateObject var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            switch viewModel.status {
            case .error(let e):
                NoContentView(title: "Error: \(e.localizedDescription)", systemImage: "exclamationmark.triangle") {
                    AsyncButton("Reconnect") {
                        await viewModel.connect()
                    }
                }
                .foregroundStyle(.red
                )
            case .notConnected:
                if case let .error(error) = viewModel.status {
                    Label("Error: \(error.localizedDescription)", systemImage: "xmark.octagon")
                        .foregroundStyle(.nordicRed)
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
                List(selection: $viewModel.selectedSSID) {
                    ssidSection()
                    
                    Section("Password") {
                        SecureField("Type Password Here", text: $viewModel.ssidPassword)
                        provisionButton()
                    }
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
            Button("OK", role: .cancel) {  }
        }

    }
    
    @ViewBuilder
    private func ssidSection() -> some View {
        Section("SSID") {
            ForEach(viewModel.ssids) { ssid in
                HStack {
                    Text(ssid.ssid)
                    Spacer()
                    if ssid == viewModel.selectedSSID {
                        Image(systemName: "checkmark")
                    }
                }
                .onTapGesture {
                    viewModel.selectedSSID = ssid
                }
            }
            
            AsyncButton("Scan") {
                await viewModel.getSSIDs()
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    private func provisionButton() -> some View {
        AsyncButton(action: {
            await viewModel.provision()
        }, label: {
            Text("Start Provisioning")
        })
        .disabled(viewModel.selectedSSID == nil)
        .buttonStyle(NordicButtonStyle())
    }
}

