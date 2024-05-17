//
//  ProvisioningPipelineButtons.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Dinesh Harjani on 17/5/24.
//

import SwiftUI

// MARK: - ProvisioningPipelineButtons

struct ProvisioningPipelineButtons: View {
    
    // MARK: Private Properties
    
    @EnvironmentObject private var viewModel: ProvisionOverWiFiView.ViewModel
    
    let onRetry: () -> Void
    let onSuccess: () -> Void
    let onClear: () -> Void
    
    // MARK: View
    
    var body: some View {
        HStack {
            if viewModel.pipelineManager.inProgress {
                ProgressView()
            } else if viewModel.pipelineManager.error != nil {
                Button("Retry", action: onRetry)
                .tint(.nordicRed)
                .buttonStyle(.borderedProminent)
            }
            
            if viewModel.pipelineManager.success {
                Button(action: onSuccess) {
                    Label("Success!", systemImage: "fireworks")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: onClear) {
                    Label("Clear", systemImage: "arrow.circlepath")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
    }
}
