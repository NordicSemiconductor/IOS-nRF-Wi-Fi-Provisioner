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
        var ipAddress: String!
        
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
    
    // MARK: setup
    
    func setupPipeline(switchingToDevice switchToDevice: Bool, andVerification verify: Bool) {
        cancellables.removeAll()
        
        var stages = ProvisioningStage.allCases
        if !switchToDevice {
            stages.removeAll(where: { $0 == .connect })
        }
        if !verify {
            stages.removeAll(where: { $0 == .switchBack || $0 == .verify })
        }
        pipelineManager = PipelineManager(initialStages: stages)
        manager.delegate = self
        
        // Setup pass-through of objectWillChange for pipeline changes
        pipelineManager.$stages.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }
    
    // MARK: pipelineStart
    
    func pipelineStart(applying configuration: NEHotspotConfiguration?) async throws {
        let startStages = pipelineManager.stagesBefore(.provision)
        let browser = BonjourBrowser()
        do {
            for stage in startStages {
                pipelineManager.inProgress(stage)
                switch stage {
                case .connect:
                    guard let configuration else { continue }
                    var networkManager = NEManager()
                    networkManager.delegate = self
                    try await networkManager.apply(configuration)
                case .browse:
                    browser.delegate = self
                    // Attempt to resolve IP Address here.
                    // If we do it later, it's more likely to fail.
                    let txtRecord = try await browser.findBonjourService(.wifiProv, preResolvingIPAddress: true)
                    try verifyTXTRecord(txtRecord)
                case .resolve:
                    log("Awaiting for Resolve...", level: .debug)
                    // Get cached IP Resolution. If not cached, attempt to resolve again.
                    let resolvedIPAddress = try await browser.resolveIPAddress(for: .wifiProv)
                    self.ipAddress = resolvedIPAddress
                    log("I've got the address! \(resolvedIPAddress)", level: .debug)
                case .scan:
                    log("Requesting Wi-Fi Scans list...", level: .info)
                    scans = try await manager.getScans(ipAddress: ipAddress)
                default:
                    break
                }
            }
        } catch {
            pipelineManager.onError(error)
            log(error.localizedDescription, level: .error)
            throw error
        }
    }
    
    // MARK: provision
    
    func provision(ipAddress: String, withVerification verify: Bool) async throws {
        guard let selectedScan else {
            throw TitleMessageError(message: "SSID is not selected")
        }
        let provisioningStages = pipelineManager.stagesFrom(.provision)
        do {
            for stage in provisioningStages {
                pipelineManager.inProgress(stage)
                switch stage {
                case .provision:
                    try await manager.provision(ipAddress: ipAddress, to: selectedScan, with: ssidPassword)
                case .switchBack:
                    log("Verification Enabled", level: .debug)
                    log("Switching to \(selectedScan.ssid)...", level: .info)
                    // Ask the user to switch to the Provisioned Network.
                    var manager = NEManager()
                    manager.delegate = self
                    let configuration = NEHotspotConfiguration(ssid: selectedScan.ssid, passphrase: ssidPassword, isWEP: selectedScan.authentication == .wep)
                    try await manager.apply(configuration)
                case .verify:
                    log("Awaiting Network Change...", level: .info)
                    
                    // Wait a couple of seconds for the firmware to make the connection switch.
                    try? await Task.sleepFor(seconds: 2)
                    
                    log("Searching for Provisioned Device in Network...", level: .info)
                    let browser = BonjourBrowser()
                    browser.delegate = self
                    let txtRecord = try await browser.findBonjourService(.wifiProv)
                    try verifyTXTRecord(txtRecord)
                default:
                    break
                }
                pipelineManager.completed(stage)
            }
        } catch {
            pipelineManager.onError(error)
            log(error.localizedDescription, level: .error)
            throw error
        }
    }
    
    // MARK: Private
    
    private func verifyTXTRecord(_ record: NWTXTRecord?) throws {
        guard let record else {
            throw TXTError.txtRecordNotFound
        }
        log("TXT Record Found", level: .info)
        guard let apiVersion = record.getEntry(for: "protovers") else {
            throw TXTError.apiVersionNotFound
        }
        log("SoftAP API Version is \(apiVersion)", level: .debug)
        guard let txtRecordVersion = record.getEntry(for: "txtvers") else {
            throw TXTError.txtVersionNotFound
        }
        log("SoftAP TXT Record Version is \(txtRecordVersion)", level: .debug)
        guard let macAddress = record.getEntry(for: "linkaddr") else {
            throw TXTError.macAddressNotFound
        }
        log("SoftAP MAC Address is \(macAddress)", level: .debug)
    }
}

// MARK: - TXTError

enum TXTError: Error, LocalizedError {
    case txtRecordNotFound
    case apiVersionNotFound
    case txtVersionNotFound
    case macAddressNotFound
    
    public var errorDescription: String? {
        localizedDescription
    }
    
    public var failureReason: String? {
        localizedDescription
    }
    
    public var localizedDescription: String {
        switch self {
        case .txtRecordNotFound:
            "No TXT Record Found."
        case .apiVersionNotFound:
            "SoftAP API Version Not Found in TXT Record."
        case .txtVersionNotFound:
            "TXT Record Version Not Found in TXT Record."
        case .macAddressNotFound:
            "MAC (Link) Address Not Found in TXT Record."
        }
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
