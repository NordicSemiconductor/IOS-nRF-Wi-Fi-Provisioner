//
//  RSSIUtil.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 20/07/2022.
//

import AsyncBluetooth
import Foundation
import NordicStyle

typealias NordicRSSI = NordicStyle.RSSI
typealias BluetoothRSSI = AsyncBluetooth.RSSI

extension NordicRSSI {
    init(signal: BluetoothRSSI) {
        switch signal.signal {
        case .good: self = .good
        case .bad: self = .bad
        case .ok: self = .ok
        case .outOfRange: self = .outOfRange
        case .practicalWorst: self = .practicalWorst
        }
    }
}
