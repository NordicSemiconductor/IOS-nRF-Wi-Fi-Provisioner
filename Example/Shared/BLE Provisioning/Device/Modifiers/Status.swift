//
//  Status.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 01/08/2022.
//

import SwiftUI
import NordicWiFiProvisioner_BLE

struct StatusModifier: ViewModifier {
    enum Status {
        case ready, inProgress, done, error
    }
    
    let status: Status
    
    func body(content: Content) -> some View {
        switch status {
        case .ready:
            content.foregroundColor(.secondary)
        case .inProgress:
            HStack(spacing: 8.0) {
                content
                
                ProgressView()
            }
            .foregroundColor(.secondary)
        case .done:
            HStack {
                content
                
                Image(systemName: "checkmark")
            }
            .foregroundColor(.green)
        case .error:
            HStack {
                content
                
                Image(systemName: "")
            }
            .foregroundColor(.red)
        }
    }
}

extension View {
    func status(_ status: StatusModifier.Status) -> some View {
        modifier(StatusModifier(status: status))
    }
}
