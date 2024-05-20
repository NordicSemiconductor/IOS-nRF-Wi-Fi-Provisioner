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
                        Label("Verification is Unreliable", systemImage: "exclamationmark.triangle.fill")
                        
                        Text("Verification may fail, but your Device could be correctly provisioned.")
                        
                        Button("Verify", action: onVerify)
                            .centered()
                    }
                }
            }
        }
    }
}
