//
//  File.swift
//  
//
//  Created by Nick Kibysh on 28/10/2022.
//

import Foundation

protocol ProtoConvertible {
    associatedtype P
    
    init(proto: P)
    
    var proto: P { get }
}
