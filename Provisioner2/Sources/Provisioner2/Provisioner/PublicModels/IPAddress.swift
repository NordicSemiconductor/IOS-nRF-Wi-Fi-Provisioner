//
//  File.swift
//  
//
//  Created by Nick Kibysh on 31/10/2022.
//

import Foundation

public struct IPAddress: CustomStringConvertible {
    private let data: Data
    
    init(data: Data) {
        self.data = data
    }
    
    public var description: String {
        data
            .map { String(format: "%02hhX", $0) }
            .joined(separator: ":")
    }
    
    
}
