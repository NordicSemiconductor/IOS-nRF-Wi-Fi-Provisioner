//
//  File.swift
//  
//
//  Created by Nick Kibysh on 31/10/2022.
//

import Foundation

public struct IPAddress: CustomStringConvertible, Equatable {
    public let data: Data
    
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
