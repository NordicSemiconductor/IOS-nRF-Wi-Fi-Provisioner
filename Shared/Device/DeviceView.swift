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
                Placeholder(text: e.message, image: "bluetooth")
            case .connected:
                devieceInfo
            }
        }
        .navigationTitle("Device Info")
    }
    
    @ViewBuilder
    var devieceInfo: some View {
        Form {
            Section() {
                Label("Device Name", image: "bluetooth")
                    .tint(.nordicBlue)
            }
            
            Section("Device Status") {
                Label("Version", systemImage: "wrench.and.screwdriver")
                
                Label("Wi-Fi Status", systemImage: "wifi")
                    .tint(.nordicBlue)
            }
        }
        
    }
}

#if DEBUG
class MockViewModel: DeviceViewModel {
    var i: Int = 0
    
    override var state: DeviceViewModel.State {
        let states: [State] = [.connecting, .connected, .failed(TitleMessageError(message: "Failed to retreive required services"))]
        
        return states[i % 3]
    }
    
    init(index: Int) {
        super.init(peripheralId: UUID())
        self.i = index
    }
}

struct DeviceView_Previews: PreviewProvider {
    
    static var previews: some View {
        NavigationView {
            DeviceView(viewModel: MockViewModel(index: 2))
        }
    }
}
#endif
