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
    
    var body: some View {
        
        VStack {
            Text("Select Mode")
                /*
            NavigationLink {
                ScannerView(viewModel: ScannerViewModel())
            } label: {
                Text("BLE Prov")
            }
            .padding()
                 */

            NavigationLink {
                Text("Wifi")
            } label: {
                Text("Wifi Prov")
            }
            .padding()
            
        }
    }
}
