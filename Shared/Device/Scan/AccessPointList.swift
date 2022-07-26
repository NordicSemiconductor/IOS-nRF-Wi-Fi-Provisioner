//
//  AccessPointList.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 26/07/2022.
//

import SwiftUI

struct AccessPointList: View {
    @ObservedObject var viewModel: DeviceViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.accessPoints) { ap in
                Button {
                    viewModel.selectedAccessPoint = ap
                    viewModel.activeScan = false 
                } label: {
                    Label(ap.name, systemImage: "lock")
                }
            }
        }
        .navigationTitle("Wi-Fi")
    }
}

struct AccessPointList_Previews: PreviewProvider {
    static var previews: some View {
        AccessPointList(viewModel: DeviceViewModel(peripheralId: UUID()))
    }
}
