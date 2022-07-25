//
//  ScannerView.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 06/07/2022.
//

import NordicStyle
import SwiftUI

#if DEBUG
	import CoreBluetoothMock
#endif

struct ScannerView: View {
	@ObservedObject var viewModel: ScannerViewModel
    @EnvironmentObject var deviceViewModelFactory: DeviceViewModelFactory

	var body: some View {
		NavigationView {
            Group {
                switch viewModel.state {
                case .noPermission:
                    Placeholder(text: "Bluetooth permission denied", image: "bluetooth_disabled")
                        .padding()
                case .scanning:
                    listView()
                case .waiting:
                    scanningPlaceholder
                case .turnedOff:
                    Placeholder(text: "Bluetooth permission denied", image: "bluetooth_disabled")
                        .padding()
                }
            }
			.navigationTitle("Scanning")
		}
		.onAppear {
			viewModel.startScan()
		}
	}
    
    @ViewBuilder
    private var scanningPlaceholder: some View {
        Placeholder(image: "bluetooth_searching")
            .padding()
    }

	@ViewBuilder
	private func listView() -> some View {
        List {
            Section {
                FilterList(
                    uuid: $viewModel.uuidFilter,
                    nearby: $viewModel.nearbyFilter,
                    named: $viewModel.nameFilter
                )
            }
            Section("Scan Results") {
                ForEach(viewModel.scanResults) { scanResult in
                    NavigationLink {
                        DeviceView(
                            viewModel: deviceViewModelFactory.viewModel(for: scanResult.id)
                        )
                    } label: {
                        Label {
                            Text(scanResult.name)
                                .lineLimit(1)
                        } icon: {
                            RSSIView(rssi: NordicRSSI(signal: scanResult.rssi))
                        }
                        .padding()
                    }
                }
            }
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
                    ScanResult(name: "Device \($0)", id: UUID(), rssi: BluetoothRSSI(level: -90))
				}
			}
		}

		static var previews: some View {
			ScannerView(viewModel: DummyScanViewModel())
		}
	}
#endif
