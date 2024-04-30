//
//  Status.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 01/08/2022.
//

import SwiftUI

// MARK: - StatusModifier

struct StatusModifier: ViewModifier {
    
    // MARK: Status
    
    enum Status {
        case ready, inProgress, done, error
        
        var isDone: Bool {
            switch self {
            case .done:
                return true
            default:
                return false
            }
        }
    }
    
    private let status: Status
    
    init(_ status: Status) {
        self.status = status
    }
    
    // MARK: ViewModifier
    
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

// MARK: - View

extension View {
    
    func status(_ status: StatusModifier.Status) -> some View {
        modifier(StatusModifier(status))
    }
}
