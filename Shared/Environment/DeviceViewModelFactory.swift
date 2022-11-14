//
//  DeviceViewModelFactory.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 21/07/2022.
//

import Foundation
import SwiftUI

class DeviceViewModelFactory: ObservableObject {
    private var viewModels: [String:DeviceViewModel] = [:]
    
    func viewModel(for peripheralId: String) -> DeviceViewModel {
        if let vm = viewModels[peripheralId] {
            return vm
        } else {
            let newViewModel = DeviceViewModel(peripheralId: peripheralId)
            viewModels[peripheralId] = newViewModel
            return newViewModel
        }
    }
}
