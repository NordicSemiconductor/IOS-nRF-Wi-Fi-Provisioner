//
//  File.swift
//  
//
//  Created by Nick Kibysh on 20/07/2022.
//

import Foundation

public struct ScanDataInfo: Identifiable {
    public var name: String
    public var id: UUID
    
    init(name: String) {
        self.name = name
        self.id = UUID()
    }
}
