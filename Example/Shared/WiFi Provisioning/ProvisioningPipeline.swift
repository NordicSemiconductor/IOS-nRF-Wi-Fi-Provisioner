//
//  ProvisioningPipeline.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Dinesh Harjani on 17/4/24.
//

import Foundation

// MARK: - ProvisioningStage

struct ProvisioningStage: PipelineStage {
    
    var id: String { symbolName }
    var totalProgress: Float { .zero }
    
    var symbolName: String
    var todoStatus: String
    var inProgressStatus: String
    var completedStatus: String
    var progress: Float
    var completed: Bool
    var inProgress: Bool
    var encounteredAnError: Bool
    
    init(symbolName: String, todoStatus: String, inProgressStatus: String, completedStatus: String) {
        self.symbolName = symbolName
        self.todoStatus = todoStatus
        self.inProgressStatus = inProgressStatus
        self.completedStatus = completedStatus
        self.progress = .zero
        self.completed = false
        self.inProgress = false
        self.encounteredAnError = false
    }
}

// MARK: - CaseIterable

extension ProvisioningStage: CaseIterable {
    
    // MARK: Cases
    
    static let connect = ProvisioningStage(symbolName: "cpu", todoStatus: "Connect to Device", inProgressStatus: "Switching to Device...", completedStatus: "Connected to Device")
    static let browse = ProvisioningStage(symbolName: "phone.arrow.up.right.fill", todoStatus: "Find Provisioning Service", inProgressStatus: "Browsing mDNS Services...", completedStatus: "Found Provisioning Service")
    static let resolve = ProvisioningStage(symbolName: "phone.arrow.down.left.fill", todoStatus: "Resolve IP Address", inProgressStatus: "Attempting to Resolve IP Address...", completedStatus: "Resolved IP Address")
    static let scan = ProvisioningStage(symbolName: "waveform.badge.magnifyingglass", todoStatus: "Scan for Available Networks", inProgressStatus: "Scanning for Networks...", completedStatus: "Scanned Available Networks")
    static let provisioningInfo = ProvisioningStage(symbolName: "hand.point.up.left.and.text.fill", todoStatus: "Await for Provisioning Information", inProgressStatus: "Waiting for Provisioning Information...", completedStatus: "User Has Provided Provisioning Information")
    static let provision = ProvisioningStage(symbolName: "keyboard.badge.ellipsis", todoStatus: "Provision Device", inProgressStatus: "Provisioning Device...", completedStatus: "Device Provisioned")
    static let switchBack = ProvisioningStage(symbolName: "network", todoStatus: "Connect to Access Point", inProgressStatus: "Switching to AP...", completedStatus: "Connected to AP")
    static let verify = ProvisioningStage(symbolName: "flag.checkered", todoStatus: "Verify", inProgressStatus: "Verifying...", completedStatus: "Successfully Provisioned")
    
    // MARK: allCases
    
    static var allCases: [ProvisioningStage] = [
        .connect, .browse, .resolve, .scan, .provisioningInfo, .provision,
        .switchBack, .verify
    ]
}
