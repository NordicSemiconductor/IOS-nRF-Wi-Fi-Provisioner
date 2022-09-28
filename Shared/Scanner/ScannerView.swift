//
//  ScannerView.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 06/07/2022.
//

import NordicStyle
import SwiftUI
import CoreBluetoothMock

struct ScannerView: View {
	@StateObject var viewModel: ScannerViewModel

	var body: some View {
        NavigationView {
            Group {
                switch viewModel.state {
                case .noPermission:
                    Placeholder(
                            text: "Bluetooth permission denied",
                            message: "Please, enable Bluetooth in Settings",
                            image: "bluetooth_disabled",
                            action: {
                                Button(action: {
                                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                                }) {
                                    Text("Open Settings")
                                }
                                        .buttonStyle(NordicButtonStyle())
                            }
                    )
                            .padding()
                case .scanning:
                    if viewModel.scanResults.isEmpty {
                        scanningPlaceholder
                    } else {
                        listView()
                    }
                case .waiting:
                    scanningPlaceholder
                case .turnedOff:
                    Placeholder(
                            text: "Bluetooth is turned off",
                            message: "Please, enable Bluetooth in Settings",
                            image: "bluetooth_disabled",
                            action: {
                                Button(action: {
                                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                                }) {
                                    Text("Open Settings")
                                }
                                        .buttonStyle(NordicButtonStyle())
                            }
                    )
                }
            }
            .navigationTitle("Scanner")
            .toolbar {
                // Filter Button
                Button(action: {
                    viewModel.onlyUnprovisioned.toggle()
                }) {
                    Image(systemName: viewModel.onlyUnprovisioned
                          ? "line.3.horizontal.decrease.circle.fill"
                          : "line.3.horizontal.decrease.circle")
                }
            }
        }
        .setupNavBarBackground()
        .accentColor(.white)
		.onAppear {
            viewModel.startScan()
        }
        .sheet(isPresented: $viewModel.showStartInfo) { IntroView(show: $viewModel.showStartInfo, dontShowAgain: $viewModel.dontShowAgain) }

    }
    
    @ViewBuilder
    private var scanningPlaceholder: some View {
        Placeholder(
                text: "Scanning for devices",
                message: "If you don't see your device check if it is turned on",
                image: "bluetooth_searching"
        )
            .padding()
    }

	@ViewBuilder
	private func listView() -> some View {
        List {
            Section {
                ForEach(viewModel.scanResults) { scanResult in

                    NavigationLink {
                        DeviceView(viewModel: DeviceViewModel(peripheralId: scanResult.id))
                    } label: {
                        Label {
                            Text(scanResult.name)
                                    .lineLimit(1)
                        } icon: {
                            RSSIView<BluetoothRSSI>(rssi: BluetoothRSSI(level: scanResult.rssi))
                        }
                                .padding()
                    }
                    .deviceAdoptiveDetail()
                }
            } header: {
                HStack {
                    Text("Devices")
                    Spacer()
                    ProgressView()
                        .isHidden((viewModel.state != .scanning), remove: true)
                }
            }
        }
        
        
	}
}

#if DEBUG
	struct ScannerView_Previews: PreviewProvider {
		class DummyScanViewModel: ScannerViewModel {
            override var showStartInfo: Bool {
                get {
                    false
                }
                set {
                    
                }
            }
            
            override var state: ScannerViewModel.State {
                .scanning
            }

			override var scanResults: [ScanResult] {
				(0...3).map { i in
                    ScanResult(
                        name: "Device \(i)",
                        rssi: -90 + i * 10,
                        id: UUID(),
                        previsioned: false
                    )
				}
			}
		}

		static var previews: some View {
            ScannerView(viewModel: DummyScanViewModel())
                .previewDisplayName("iPhone 13")
		}
	}
#endif
