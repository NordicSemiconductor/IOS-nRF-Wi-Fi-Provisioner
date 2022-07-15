//
//  ScannerView.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 06/07/2022.
//

import SwiftUI
#if DEBUG
import nRF_BLE
import CoreBluetoothMock
import Combine
#endif

struct ScannerView: View {
    @ObservedObject var viewModel: ScannerViewModel
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.scanResults) { scanResult in
                    Label(scanResult.name, systemImage: "cpu")
                        .padding()
                }
            }
            .navigationTitle("Scanning")
        }
        .onAppear {
            viewModel.startScan()
        }
    }
        
}

#if DEBUG
struct ScannerView_Previews: PreviewProvider {
    class DummyScanViewModel: ScannerViewModel {
        override func startScan() {
            
        }
        
        override var scanResults: [ScanResult] {
            return (0...3).map {
                ScanResult(name: "Device \($0)", id: UUID())
            }
        }
    }
    
    static var previews: some View {
        ScannerView(viewModel: DummyScanViewModel())
    }
}
#endif
