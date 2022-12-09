//
//  File.swift
//  
//
//  Created by Nick Kibysh on 31/10/2022.
//

import Foundation

/// Representation of MAC-48 identifier
public struct MACAddress: CustomStringConvertible, Equatable, Hashable {
    let data: Data
    
    /// Creates an instance of `MACAddress` from a string.
    ///
    /// - parameter data: 6 bytes of data. Data should be 48 bit length, otherwise nil will be returned.
    public init?(data: Data) {
        guard data.count == 6 else { return nil }
        self.data = data
    }
    
    public var description: String {
        data
            .map { String(format: "%02hhX", $0) }
            .joined(separator: ":")
    }
}
