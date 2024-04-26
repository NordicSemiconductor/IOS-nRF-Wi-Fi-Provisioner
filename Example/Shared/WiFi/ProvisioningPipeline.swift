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
    
    static let connected = ProvisioningStage(symbolName: "network", todoStatus: "Connect to Device", inProgressStatus: "Switching to Endpoint...", completedStatus: "Connected to DK")
    static let browsed = ProvisioningStage(symbolName: "phone.arrow.up.right.fill", todoStatus: "Find Provisioning Service", inProgressStatus: "Browsing mDNS Services...", completedStatus: "Find Provisioning Service")
    static let resolved = ProvisioningStage(symbolName: "phone.arrow.down.left.fill", todoStatus: "Resolve IP Address", inProgressStatus: "Attempting To Resolve IP Address...", completedStatus: "Resolved IP Address")
    static let scanned = ProvisioningStage(symbolName: "waveform.badge.magnifyingglass", todoStatus: "Scan For Available Networks", inProgressStatus: "Scanning For Networks...", completedStatus: "Scanned Available Networks")
    static let provisioningInfo = ProvisioningStage(symbolName: "hand.point.up.left.and.text.fill", todoStatus: "Await For Provisioning Information", inProgressStatus: "Waiting For Provisioning Information...", completedStatus: "User Has Provided Provisioning Information")
    static let provisioning = ProvisioningStage(symbolName: "keyboard.badge.ellipsis", todoStatus: "Provision Device", inProgressStatus: "Provisioning Device...", completedStatus: "Device Provisioned")
    static let verification = ProvisioningStage(symbolName: "flag.checkered", todoStatus: "Verify", inProgressStatus: "Verifying...", completedStatus: "Successfully Provisioned")
    
    // MARK: allCases
    
    static var allCases: [ProvisioningStage] = [
        .connected, .browsed, .resolved, .scanned, .provisioningInfo, .provisioning, .verification
    ]
}
