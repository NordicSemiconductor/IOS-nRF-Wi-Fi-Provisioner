//
//  File.swift
//  
//
//  Created by Nick Kibysh on 15/11/2022.
//

import Foundation
import Provisioner2

extension ScanParams {
    static let sp1 = ScanParams(band: .band5Gh, passive: true, periodMs: 100, groupChannels: 1)
    static let sp2 = ScanParams(band: .band24Gh, passive: false, periodMs: 200, groupChannels: 2)
    static let sp3 = ScanParams(band: .any, passive: true, periodMs: 300, groupChannels: 3)
}
