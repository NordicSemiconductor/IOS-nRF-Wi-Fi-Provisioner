//
//  File.swift
//  
//
//  Created by Nick Kibysh on 19/12/2022.
//

import Foundation

extension Int {
    func toData() -> Data {
        var value = self
        let data = Data(bytes: &value, count: MemoryLayout.size(ofValue: value))
        let arr = [UInt8](data)
        return Data(arr.reversed())
    }
}
