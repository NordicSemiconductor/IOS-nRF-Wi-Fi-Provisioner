//
//  DeviceViewModelFactory.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 21/07/2022.
//

import Foundation
import SwiftUI

class DeviceViewModelFactory: ObservableObject {
    private var viewModels: [String:DeviceView.ViewModel] = [:]
    
    func viewModel(for peripheralId: String) -> DeviceView.ViewModel {
        if let vm = viewModels[peripheralId] {
            return vm
        } else {
            let newViewModel = DeviceView.ViewModel(deviceId: peripheralId)
            viewModels[peripheralId] = newViewModel
            return newViewModel
        }
    }
}


