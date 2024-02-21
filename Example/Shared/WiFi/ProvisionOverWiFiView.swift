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
            case .notConnected, .error:
                if case let .error(error) = viewModel.status {
                    Label("Error: \(error.localizedDescription)", systemImage: "xmark.octagon")
                        .foregroundStyle(.nordicRed)
                        .padding()
                }
                AsyncButton("Attempt to Connect") {
                    await viewModel.connect()
                }
            case .connecting:
                ProgressView()
                    .progressViewStyle(.circular)
                
                Text("Connecting...")
            case .connected:
                List(selection: $viewModel.selectedSSID) {
                    Section("LED Testing") {
                        AsyncButton {
                            await viewModel.toggleLedStatus(ledNumber: 1)
                        } label: {
                            Label("LED 1", systemImage: ledSystemImage(status: viewModel.led1Status))
                        }
                        .disabled(viewModel.led1Status.disabled)
                        
                        AsyncButton {
                            await viewModel.toggleLedStatus(ledNumber: 2)
                        } label: {
                            Label("LED 2", systemImage: ledSystemImage(status: viewModel.led2Status))
                        }
                        .disabled(viewModel.led2Status.disabled)
                    }
                    
                    ssidSection()
                    
                    Section("Password") {
                        SecureField("Type Password Here", text: $viewModel.ssidPassword)
                        provisionButton()
                    }
                }
                .task {
                    await viewModel.readLedStatus()
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
            
        }, label: {
            Text("Start Provisioning")
        })
        .disabled(viewModel.selectedSSID == nil)
        .buttonStyle(NordicButtonStyle())
    }
    
    private func ledSystemImage(status: ViewModel.LedStatus) -> String {
        switch status {
        case .on:
            return "lightbulb.fill"
        case .off:
            return "lightbulb"
        default:
            return "lightbulb.slash"
        }
    }
}

