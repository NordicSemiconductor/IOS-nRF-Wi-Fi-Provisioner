//
//  DeviceView.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 19/07/2022.
//

import SwiftUI
import NordicStyle

struct DeviceView: View {
    @ObservedObject var viewModel: DeviceViewModel
    
    var body: some View {
        VStack {
            switch viewModel.state {
            case .connecting:
                Placeholder(
                    text: "Connecting",
                    image: "bluetooth"
                )
            case .failed(let e):
                Placeholder(text: e.message, image: "bluetooth_disabled")
            case .connected:
                devieceInfo
            }
        }
        .navigationTitle("Device Info")
        .onAppear {
            Task {
                do {
                    try await viewModel.connect()
                }
            }
        }
        .alert(viewModel.errorTitle ?? "", isPresented: $viewModel.showErrorAlert) {
            Button("OK", role: .cancel) {
                
            }
        }
    }
    
    @ViewBuilder
    var devieceInfo: some View {
        Form {
            Section() {
                Label("Device Name", image: "bluetooth")
                    .tint(.nordicBlue)
            }
            
            Section("Device Status") {
                HStack {
                    Label("Version", systemImage: "wrench.and.screwdriver")
                    
                }
                
                Label("Wi-Fi Status", systemImage: "wifi")
                    .tint(.nordicBlue)
            }
        }
        
    }
}

#if DEBUG
struct DeviceView_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            DeviceView(viewModel: MockDeviceViewModel(index: 2))
        }
    }
}
#endif
