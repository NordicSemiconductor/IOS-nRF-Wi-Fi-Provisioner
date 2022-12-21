//
//  File.swift
//  
//
//  Created by Nick Kibysh on 16/12/2022.
//

import Foundation
import CoreBluetoothMock

extension CBMUUID {
    static let version =        CBMUUID(string: "14387801-130c-49e7-b877-2881c89cb258")
    static let controlPoint =   CBMUUID(string: "14387802-130c-49e7-b877-2881c89cb258")
    static let dataOut =        CBMUUID(string: "14387803-130c-49e7-b877-2881c89cb258")
    static let wifi =           CBMUUID(string: "14387800-130c-49e7-b877-2881c89cb258")
}

extension CBMCharacteristicMock {
    static let version = CBMCharacteristicMock(type: .version, properties: [.read])
    static let controlPoint = CBMCharacteristicMock(type: .controlPoint, properties: [.write, .notify])
    static let dataOut = CBMCharacteristicMock(type: .dataOut, properties: [.notify])
}
