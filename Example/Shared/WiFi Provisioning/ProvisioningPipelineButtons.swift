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
    
    // MARK: Properties
    
    let onClear: () -> Void
    let onRetry: () -> Void
    let onSuccess: () -> Void
    
    // MARK: View
    
    var successButtonString: String {
        viewModel.pipelineManager.success ? "Success!" : "Done"
    }
    
    var successSystemImageString: String {
        viewModel.pipelineManager.success ? "fireworks" : "checkmark"
    }
    
    var body: some View {
        HStack {
            if viewModel.pipelineManager.inProgress {
                ProgressView()
            } else {
                if viewModel.pipelineManager.isCompleted(.provision) {
                    Button(action: onSuccess) {
                        Label(successButtonString, systemImage: successSystemImageString)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button(action: onClear) {
                        Label("Clear", systemImage: "arrowshape.backward.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    
                    Button(action: onRetry) {
                        Label("Retry", systemImage: "arrow.counterclockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .tint(.nordicRed)
                    .buttonStyle(.borderedProminent)
                }
            }
        }
    }
}
