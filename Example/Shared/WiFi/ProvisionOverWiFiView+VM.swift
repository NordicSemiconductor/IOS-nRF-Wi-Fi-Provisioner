//
//  ProvisionOverWiFiView+VM.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 20/02/2024.
//

import SwiftUI
import NordicWiFiProvisioner_SoftAP
import OSLog
import Combine

// MARK: - ProvisionOverWiFiView.ViewModel

extension ProvisionOverWiFiView {
    
    @MainActor
    class ViewModel: ObservableObject {
        
        @Published private(set) var pipelineManager = PipelineManager(initialStages: ProvisioningStage.allCases)
        @Published private(set) var logLine = ""
        
        private var manager = ProvisionManager()
        var ipAddress: String?
        
        @Published private (set) var scans: [APWiFiScan] = []
        @Published var selectedScan: APWiFiScan?
        @Published var ssidPassword: String = ""
        
        private let log = Logger(subsystem: Bundle.main.bundleIdentifier!, 
                                 category: "ProvisionOverWiFiView+ViewModel")
        private lazy var cancellables = Set<AnyCancellable>()
    }
}

// MARK: - ViewModel API

extension ProvisionOverWiFiView.ViewModel {
    
    func pipelineStart() async throws {
        resetPipeline()
        
        do {
            pipelineManager.inProgress(.connected)
            try await manager.connect()
            
            pipelineManager.inProgress(.browsed)
            let service = try await manager.findBonjourService(type: "_http._tcp.", domain: "local", name: "wifiprov")
            
            pipelineManager.inProgress(.resolved)
            log("Awaiting for Resolve...", level: .debug)
            let resolvedIPAddress = try await manager.resolveIPAddress(for: service)
            self.ipAddress = resolvedIPAddress
            log("I've got the address! \(resolvedIPAddress)", level: .debug)
            
            pipelineManager.inProgress(.scanned)
            scans = try await manager.getScans(ipAddress: resolvedIPAddress)
            
            pipelineManager.inProgress(.provisioningInfo)
        } catch {
            pipelineManager.onError(error)
            log("Pipeline Error: \(error.localizedDescription)", level: .error)
            throw error
        }
    }
    
    func provision(ipAddress: String) async throws {
        do {
            guard let selectedScan else {
                throw TitleMessageError(message: "SSID is not selected")
            }
            pipelineManager.inProgress(.provisioning)
            
            try await manager.provision(ipAddress: ipAddress, to: selectedScan, with: ssidPassword)
            pipelineManager.inProgress(.verification)
            
            try await manager.verifyProvisioning(to: selectedScan, with: ssidPassword)
            pipelineManager.completed(.verification)
        } catch {
            pipelineManager.onError(error)
            log("Pipeline Error: \(error.localizedDescription)", level: .error)
            throw error
        }
    }
    
    // MARK: Private
    
    private func resetPipeline() {
        cancellables.removeAll()
        
        pipelineManager = PipelineManager(initialStages: ProvisioningStage.allCases)
        manager.delegate = self
        
        // Setup pass-through of objectWillChange for pipeline changes
        pipelineManager.$stages.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }
}

// MARK: ProvisionManager.Delegate

extension ProvisionOverWiFiView.ViewModel: ProvisionManager.Delegate {
    
    func log(_ line: String, level: OSLogType) {
        switch level {
        case .debug:
            log.debug("\(line)")
        case .info:
            log.info("\(line)")
        case .error:
            log.error("\(line)")
        case .fault:
            log.fault("\(line)")
        default:
            log.log("\(line)")
        }
        Task { @MainActor in
            logLine = line
        }
    }
}
