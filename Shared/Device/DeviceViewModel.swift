//
//  DeviceViewModel.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 19/07/2022.
//

import Foundation

class DeviceViewModel: ObservableObject {
    enum State {
        case connecting, failed(ReadableError), connected
    }
    
    @Published private (set) var state: State = .connected
    
    let peripheral: UUID
    
    init(peripheralId: UUID) {
        self.peripheral = peripheralId
    }
    
    
}
