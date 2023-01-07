//
// Created by Nick Kibysh on 10/10/2022.
//

import Foundation
import CoreBluetoothMock

/// UUIDs of the services used in the provisioning process.
public struct ServiceID {
    /// The Wi-Fi Provisioning Service identifier.
    ///
    /// Equal to `0x14387800-130c-49e7-b877-2881c89cb258`.
    public static let wifi = UUID(uuidString: "14387800-130c-49e7-b877-2881c89cb258")!
}

/// UUIDs of the characteristics used in the provisioning process.
public struct CharacteristicID {
    
    /// UUID of Version Information Characteristic.
    ///
    /// This characteristic describes the version of the current implementation of the Wi-Fi provisioning service.
    ///
    /// Equal to **`14387801-130c-49e7-b877-2881c89cb258`**.
    public static let version = UUID(uuidString: "14387801-130c-49e7-b877-2881c89cb258")!
    
    /// UUID of Operation Control Point Characteristic.
    ///
    /// Equal to **`14387802-130c-49e7-b877-2881c89cb258`**.
    public static let controlPoint = UUID(uuidString: "14387802-130c-49e7-b877-2881c89cb258")!
    
    /// UUID of Data Out Characteristic.
    ///
    /// This characteristic is used to send notifications to the client.
    ///
    /// Equal to **`14387803-130c-49e7-b877-2881c89cb258`**.
    public static let dataOut = UUID(uuidString: "14387803-130c-49e7-b877-2881c89cb258")!
}

