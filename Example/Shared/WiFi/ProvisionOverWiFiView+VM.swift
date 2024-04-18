//
//  ProvisionOverWiFiView+VM.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 20/02/2024.
//

import SwiftUI
import NordicWiFiProvisioner_SoftAP
import OSLog

// MARK: - ProvisionOverWiFiView.ViewModel

extension ProvisionOverWiFiView {
    
    @MainActor
    class ViewModel: ObservableObject {
        
        @Published var pipelineManager = PipelineManager(initialStages: ProvisioningStage.allCases)
        
        private var manager = ProvisionManager()
        var ipAddress: String?
        
        @Published private (set) var scans: [APWiFiScan] = []
        @Published var selectedScan: APWiFiScan?
        @Published var ssidPassword: String = ""
        
        @Published private (set) var alertError: TitleMessageError? = nil
        @Published var showAlert: Bool = false
        
        private let log = Logger(subsystem: Bundle.main.bundleIdentifier!, 
                                 category: "ProvisionOverWiFiView+ViewModel")
    }
}

// MARK: - ViewModel API

extension ProvisionOverWiFiView.ViewModel {
    
    func pipelineStart() async {
        pipelineManager = PipelineManager(initialStages: ProvisioningStage.allCases)
        do {
            pipelineManager.inProgress(.connected)
            objectWillChange.send()
            try await manager.connect()
            
            pipelineManager.inProgress(.browsed)
            objectWillChange.send()
            let service = try await manager.findBonjourService(type: "_http._tcp.", domain: "local")
            
            print(service)
            pipelineManager.inProgress(.resolved)
            objectWillChange.send()
            log.debug("Awaiting for Resolve...")
            let resolvedIPAddress = try await BonjourResolver.resolve(service)
            self.ipAddress = resolvedIPAddress
            print(resolvedIPAddress)
            log.debug("I've got the address! \(resolvedIPAddress)")
            
            pipelineManager.inProgress(.scanned)
            objectWillChange.send()
            scans = try await manager.getScans(ipAddress: resolvedIPAddress)
            
            pipelineManager.inProgress(.provisioningInfo)
            objectWillChange.send()
        } catch {
            pipelineManager.onError(error)
            objectWillChange.send()
            log.error("Pipeline Error: \(error.localizedDescription)")
            alertError = TitleMessageError(error)
            showAlert = true
        }
    }
    
    func provision(ipAddress: String) async {
        do {
            pipelineManager.inProgress(.provisioning)
            objectWillChange.send()
            
            guard let ssid = selectedScan?.ssid else {
                throw TitleMessageError(message: "SSID is not selected")
            }
            
            let password = ssidPassword.isEmpty ? nil : ssidPassword
            try await manager.provision(ipAddress: ipAddress, ssid: ssid, password: password)
            
        } catch {
            pipelineManager.onError(error)
            objectWillChange.send()
            log.error("Pipeline Error: \(error.localizedDescription)")
            alertError = TitleMessageError(error)
            showAlert = true
        }
    }
}
