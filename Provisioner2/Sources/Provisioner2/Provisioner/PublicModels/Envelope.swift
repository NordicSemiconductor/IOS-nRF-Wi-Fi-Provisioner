//
//  File.swift
//  
//
//  Created by Nick Kibysh on 28/10/2022.
//

import Foundation

struct Envelope<P> {
    var model: P
    
    init(model: P) {
        self.model = model
    }
}
