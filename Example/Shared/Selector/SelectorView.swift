//
//  SelectorView.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Dinesh Harjani on 12/2/24.
//

import SwiftUI

struct SelectorView: View {
    
    enum Mode: CustomStringConvertible, CaseIterable {
        case provisionOverBle
        case provisionOverWifi
        
        var description: String {
            switch self {
            case .provisionOverBle:
                "Provision over BLE"
            case .provisionOverWifi:
                "Provision over Wi-Fi"
            }
        }
    }
    
    @Binding var selected: Mode?
    
    var body: some View {
        Text("Select Mode")
        
        ForEach(Mode.allCases, id: \.description) { mode in
            Button(mode.description) {
                selected = mode
            }
        }
    }
}
