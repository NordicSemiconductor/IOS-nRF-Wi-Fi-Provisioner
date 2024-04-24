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
    
    @State private var viewStatus: ViewStatus = .showingStages
    enum ViewStatus {
        case showingStages
        case awaitingUserInput
    }
    
    // MARK: View
    
    var body: some View {
        VStack {
            switch viewStatus {
            case .showingStages:
                List {
                    Section {
                        ForEach(viewModel.pipelineManager.stages) { stage in
                            PipelineView(stage: stage, logLine: "")
                        }
                    }
                }
                
                Spacer()
                
                AsyncButton("Start") {
                    await viewModel.pipelineStart()
                    viewStatus = .awaitingUserInput
                }
            case .awaitingUserInput:
                List(selection: $viewModel.selectedScan) {
                    ssidSection()
                    
                    Section("Password") {
                        SecureField("Type Password Here", text: $viewModel.ssidPassword)
                        
                        if let ipAddress = viewModel.ipAddress {
                            provisionButton(ipAddress: ipAddress)
                        }
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
            
//            AsyncButton("Scan") {
//                await viewModel.getScans()
//            }
//            .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    private func provisionButton(ipAddress: String) -> some View {
        AsyncButton(action: {
            await viewModel.provision(ipAddress: ipAddress)
        }, label: {
            Text("Provision")
        })
        .disabled(viewModel.selectedScan == nil)
        .accessibilityIdentifier("prov_button")
    }
}

