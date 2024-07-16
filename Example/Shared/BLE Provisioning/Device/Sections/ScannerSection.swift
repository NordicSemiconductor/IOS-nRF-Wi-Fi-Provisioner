//
//  ScannerSection.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Dinesh Harjani on 9/4/24.
//

import SwiftUI

// MARK: - ScannerSection

struct ScannerSection: View {
    
    // MARK: Properties
    
    @EnvironmentObject private var viewModel: DeviceView.ViewModel
    
    // MARK: View
    
    var body: some View {
        Section("Scanner") {
            ForEach(viewModel.accessPoints) { accessPoint in
                APWiFiScanView(wiFiScan: accessPoint, selected: viewModel.wifiNetwork == accessPoint.wifi)
                    .onTapGesture {
                        viewModel.wifiNetwork = accessPoint.wifi
                    }
                    .tag(accessPoint.wifi)
            }
            
            AsyncButton("Scan") {
                viewModel.startScanning()
            }
            .disabled(!viewModel.peripheralConnectionStatus.isConnected)
            .frame(maxWidth: .infinity)
        }
    }
}
