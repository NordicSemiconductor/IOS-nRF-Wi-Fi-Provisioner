//
//  ProvisionOverWiFiView.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Dinesh Harjani on 12/2/24.
//

import SwiftUI
import iOS_Common_Libraries
import NordicWiFiProvisioner_SoftAP
import NetworkExtension

// MARK: - ProvisionOverWiFiView

struct ProvisionOverWiFiView: View {
    
    // MARK: Properties
    
    @StateObject var viewModel = ViewModel()
    
    @State private var alertError: TitleMessageError? = nil
    @State private var showAlert: Bool = false
    @State private var viewStatus: ViewStatus = .showingStages
    
    private enum ViewStatus {
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
                            PipelineView(stage: stage, logLine: viewModel.logLine)
                        }
                    }
                }
                
                Spacer()
                
                AsyncButton("Start") {
                    do {
                        let apSSID = "nrf-wifiprov"
                        let configuration = NEHotspotConfiguration(ssid: apSSID)
                        try await viewModel.pipelineStart(applying: configuration)
                        viewStatus = .awaitingUserInput
                    } catch {
                        viewStatus = .showingStages
                        alertError = TitleMessageError(error)
                        showAlert = true
                    }
                }
            case .awaitingUserInput:
                List(selection: $viewModel.selectedScan) {
                    ssidSection()
                    
                    AccessPointSection(accessPoint: viewModel.selectedScan?.accessPoint(), password: $viewModel.ssidPassword, showVolatileMemory: false, volatileMemory: $viewModel.volatileMemory, footer: "")
                    
                    if let ipAddress = viewModel.ipAddress {
                        provisionButton(ipAddress: ipAddress)
                    }
                }
            }
        }
        .navigationTitle("Provision over Wi-Fi")
        .alert(isPresented: $showAlert, error: alertError) {
            Button("OK", role: .cancel) { 
                alertError = nil
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
        }
    }
    
    @ViewBuilder
    private func provisionButton(ipAddress: String) -> some View {
        AsyncButton("Provision") {
            do {
                viewStatus = .showingStages
                try await viewModel.provision(ipAddress: ipAddress)
            } catch {
                alertError = TitleMessageError(error)
                showAlert = true
            }
        }
        .disabled(viewModel.selectedScan == nil)
        .accessibilityIdentifier("prov_button")
    }
}
