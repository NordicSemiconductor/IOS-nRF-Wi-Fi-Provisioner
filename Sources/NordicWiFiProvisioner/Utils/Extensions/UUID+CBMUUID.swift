//
//  UUID+CBMUUID.swift
//  NordicWiFiProvisioner
//
//  Created by Nick Kibysh on 28/12/2022.
//

import Foundation
import CoreBluetoothMock

extension UUID {
    var cbm: CBMUUID {
        CBMUUID(string: uuidString)
    }
}

extension CBMUUID {
    var uuid: UUID {
        UUID(uuidString: uuidString)!
    }
}
