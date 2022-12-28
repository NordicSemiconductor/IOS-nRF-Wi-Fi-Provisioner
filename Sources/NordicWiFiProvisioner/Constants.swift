//
// Created by Nick Kibysh on 10/10/2022.
//

import Foundation
import CoreBluetoothMock

public struct ServiceID {
    static let wifi = UUID(uuidString: "14387800-130c-49e7-b877-2881c89cb258")!
}

public struct CharacteristicID {
    static let version = UUID(uuidString: "14387801-130c-49e7-b877-2881c89cb258")!
    static let controlPoint = UUID(uuidString: "14387802-130c-49e7-b877-2881c89cb258")!
    static let dataOut = UUID(uuidString: "14387803-130c-49e7-b877-2881c89cb258")!
}

