//
//  File.swift
//  
//
//  Created by Nick Kibysh on 12/07/2022.
//

import Foundation
import SwiftUI

public
struct ScanResult: Identifiable {
    public let name: String?
    public let id: UUID
    
    public init(name: String?, id: UUID) {
        self.name = name
        self.id = id 
    }
}
