//
//  Status.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 01/08/2022.
//

import SwiftUI
import Provisioner

struct WiFiStatusColorModifier: ViewModifier {
    let status: WiFiStatus
    
    func body(content: Content) -> some View {
        switch status {
        case .connected:
            content.foregroundColor(.green)
        case .connectionFailed(_):
            content.foregroundColor(.red)
        default:
            content.foregroundColor(.secondary)
        }
    }
}

extension View {
    func status(_ status: WiFiStatus) -> some View {
        modifier(WiFiStatusColorModifier(status: status))
    }
}
