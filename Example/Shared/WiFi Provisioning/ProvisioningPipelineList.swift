//
//  ProvisioningPipelineList.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Dinesh Harjani on 17/5/24.
//

import SwiftUI

// MARK: - ProvisioningPipelineList

struct ProvisioningPipelineList: View {
    
    // MARK: Private Properties
    
    @EnvironmentObject private var viewModel: ProvisionOverWiFiView.ViewModel
    
    // MARK: Properties
    
    let onVerify: () -> Void
    
    // MARK: View
    
    var body: some View {
        List {
            if let connectionStage = viewModel.pipelineManager.connectionStage {
                Section("Connection") {
                    PipelineView(stage: connectionStage, logLine: viewModel.logLine)
                }
            }
            
            Section("Provisioning") {
                ForEach(viewModel.pipelineManager.provisioningStages()) { stage in
                    PipelineView(stage: stage, logLine: viewModel.logLine)
                }
            }
            
            if viewModel.pipelineManager.isCompleted(.provision) {
                Section("Verification") {
                    if viewModel.attemptedToVerify {
                        ForEach(viewModel.pipelineManager.verificationStages()) { stage in
                            PipelineView(stage: stage, logLine: viewModel.logLine)
                        }
                    } else {
                        Label("Verification adds a couple of extra steps involving Network Configuration changes on your iPhone that might throw errors, but your Device might've still been successfully provisioned.", systemImage: "exclamationmark.triangle.fill")
                        
                        Button("Verify", action: onVerify)
                            .centered()
                    }
                }
            }
        }
    }
}
