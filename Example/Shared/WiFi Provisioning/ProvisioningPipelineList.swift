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
            
            if viewModel.pipelineManager.isCompleted(.provision), viewModel.pipelineManager.finishedWithError {
                Section("Verification") {
                    Label("Even if Provisioning Verification fails, your device might've still been provisioned successfully.", systemImage: "info.bubble.fill")
                        .labelStyle(.colorIconOnly(.green))
                }
            }
        }
    }
}
