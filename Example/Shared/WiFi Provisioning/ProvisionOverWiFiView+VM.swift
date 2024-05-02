//
//  ProvisionOverWiFiView+VM.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 20/02/2024.
//

import SwiftUI
import NordicWiFiProvisioner_SoftAP
import NetworkExtension
import OSLog
import Combine

// MARK: - ProvisionOverWiFiView.ViewModel

extension ProvisionOverWiFiView {
    
    @MainActor
    class ViewModel: ObservableObject {
        
        @Published private(set) var pipelineManager = PipelineManager(initialStages: ProvisioningStage.allCases)
        @Published private(set) var logLine = ""
        
        private let manager = {
            let res: URL! = Bundle.main.url(forResource: "certificate", withExtension: "cer")!
            let manager = ProvisionManager(certificateURL: res)
            return manager
        }()
        var ipAddress: String?
        
        @Published private (set) var scans: [APWiFiScan] = []
        @Published var selectedScan: APWiFiScan?
        @Published var ssidPassword: String = ""
        @Published var volatileMemory = false
        
        private let log = Logger(subsystem: Bundle.main.bundleIdentifier!, 
                                 category: "ProvisionOverWiFiView+ViewModel")
        private lazy var cancellables = Set<AnyCancellable>()
    }
}

// MARK: - ViewModel API

extension ProvisionOverWiFiView.ViewModel {
    
    func pipelineStart(applying configuration: NEHotspotConfiguration?) async throws {
        resetPipeline()
        
        do {
            pipelineManager.inProgress(.connected)
            if let configuration {
                var networkManager = NEManager()
                networkManager.delegate = self
                try await networkManager.apply(configuration)
            } else {
                log("No Configuration to apply.", level: .debug)
                log("Assumption: we're already connected to Device.", level: .info)
                pipelineManager.completed(.connected)
            }
            
            pipelineManager.inProgress(.browsed)
            let browser = BonjourBrowser()
            browser.delegate = self
            _ = try await browser.findBonjourService(.wifiProv)
            
            pipelineManager.inProgress(.resolved)
            log("Awaiting for Resolve...", level: .debug)
            let resolvedIPAddress = try await browser.resolveIPAddress(for: .wifiProv)
            self.ipAddress = resolvedIPAddress
            log("I've got the address! \(resolvedIPAddress)", level: .debug)
            
            pipelineManager.inProgress(.scanned)
            log("Requesting Wi-Fi Scans list...", level: .info)
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
            
            pipelineManager.inProgress(.switchBack)
            log("Switching to \(selectedScan.ssid)...", level: .info)
            // Ask the user to switch to the Provisioned Network.
            var manager = NEManager()
            manager.delegate = self
            let configuration = NEHotspotConfiguration(ssid: selectedScan.ssid, passphrase: ssidPassword, isWEP: selectedScan.authentication == .wep)
            try await manager.apply(configuration)
            
            pipelineManager.inProgress(.verification)
            log("Awaiting Network Change...", level: .info)
            
            // Wait a couple of seconds for the firmware to make the connection switch.
            try? await Task.sleepFor(seconds: 2)
            
            log("Searching for Provisioned Device in Network...", level: .info)
            let browser = BonjourBrowser()
            browser.delegate = self
            let txtRecord = try await browser.findBonjourService(.wifiProv)
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

// MARK: BonjourService

extension BonjourService {
    
    static let wifiProv = BonjourService(name: "wifiprov", domain: "local",
                                         type: "_http._tcp.")
}