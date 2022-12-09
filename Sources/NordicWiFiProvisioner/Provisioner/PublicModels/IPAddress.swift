//
//  File.swift
//  
//
//  Created by Nick Kibysh on 31/10/2022.
//

import Foundation

/// A struct that represents IPv4 address.
public struct IPAddress: CustomStringConvertible, Equatable {
    /// IP Address raw data. 
    public let data: Data
    
    /// Creates an instance of `IPAddress` from a data.
    ///
    /// - parameter data: 4 bytes of data. If the length of the data is not 4, the initializer will return `nil`.
    public init?(data: Data) {
        guard data.count == 4 else { return nil }
        self.data = data
    }
    
    public var description: String {
        data
            .map { String(format: "%d", $0) }
            .joined(separator: ".")
    }
}
