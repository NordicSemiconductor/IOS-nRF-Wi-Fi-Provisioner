//
//  ScannerView.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 06/07/2022.
//

import SwiftUI
import nRF_BLE
import NordicStyle
#if DEBUG
import CoreBluetoothMock
#endif

struct ScannerView: View {
    @ObservedObject var viewModel: ScannerViewModel
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    FilterList(uuid: $viewModel.uuidFilter, nearby: $viewModel.nearbyFilter, named: $viewModel.nameFilter)
                }
                Section("Scan Results") {
                    ForEach(viewModel.scanResults) { scanResult in
                        NavigationLink {
                            Text("")
                        } label: {
                            Label {
                                Text(scanResult.name)
                                    .lineLimit(1)
                            } icon: {
                                RSSIView(rssi: scanResult.rssi)
                            }
                            .padding()
                        }
                    }
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
                ScanResult(name: "Device \($0)", id: UUID(), rssi: RSSI(level: -90))
            }
        }
    }
    
    static var previews: some View {
        ScannerView(viewModel: DummyScanViewModel())
    }
}
#endif
