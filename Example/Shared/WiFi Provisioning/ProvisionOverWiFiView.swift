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
    
    private static let DEFAULT_SSID = "nrf-wifiprov"
    
    // MARK: Properties
    
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject var viewModel = ViewModel()
    
    @State private var alertError: TitleMessageError? = nil
    @State private var showAlert = false
    @State private var viewStatus: ViewStatus = .setup
    @State private var switchToAccessPoint = true
    @State private var name = Self.DEFAULT_SSID
    @State private var verify = true
    
    enum ViewStatus {
        case setup
        case showingStages
        case awaitingUserInput
    }
    
    // MARK: View
    
    var body: some View {
        VStack {
            switch viewStatus {
            case .setup:
                ProvisioningConfiguration(switchToAccessPoint: $switchToAccessPoint, ssid: $name, verifyProvisioning: $verify) {
                    startProvisioning()
                }
            case .showingStages:
                List {
                    Section("Steps") {
                        ForEach(viewModel.pipelineManager.stages) { stage in
                            PipelineView(stage: stage, logLine: viewModel.logLine)
                        }
                    }
                }
                
                Spacer()
                
                HStack {
                    if viewModel.pipelineManager.inProgress {
                        ProgressView()
                    } else if viewModel.pipelineManager.error != nil {
                        Button("Retry") {
                            startProvisioning()
                        }
                        .tint(.nordicRed)
                        .buttonStyle(.borderedProminent)
                    }
                    
                    if viewModel.pipelineManager.success {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Text("Success!")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button {
                            viewStatus = .setup
                        } label: {
                            Text("Clear")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
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
        .background(Color.formBackground)
        .navigationTitle("Provision over Wi-Fi")
        .alert(isPresented: $showAlert, error: alertError) {
            Button("OK", role: .cancel) { 
                alertError = nil
            }
        }
    }
    
    // MARK: startProvisioning
    
    private func startProvisioning() {
        Task { @MainActor in
            alertError = nil
            showAlert = false
            viewStatus = .showingStages
            do {
                viewModel.setupPipeline(switchingToDevice: switchToAccessPoint,
                                        andVerification: verify)
                let configuration = NEHotspotConfiguration(ssid: name)
                try await viewModel.pipelineStart(applying: configuration)
                viewStatus = .awaitingUserInput
            } catch {
                viewStatus = .showingStages
                alertError = TitleMessageError(error)
                showAlert = true
            }
        }
    }
    
    // MARK: ssidSection
    
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
    
    // MARK: provisionButton
    
    @ViewBuilder
    private func provisionButton(ipAddress: String) -> some View {
        AsyncButton("Provision") {
            do {
                viewStatus = .showingStages
                try await viewModel.provision(ipAddress: ipAddress, withVerification: verify)
            } catch {
                alertError = TitleMessageError(error)
                showAlert = true
            }
        }
        .frame(maxWidth: .infinity)
        .disabled(viewModel.selectedScan == nil)
        .accessibilityIdentifier("prov_button")
    }
}
