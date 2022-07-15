//
//  Array+Ext.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 13/07/2022.
//

import Foundation

extension Array where Element : Hashable {
    
    @discardableResult
    mutating
    func insertIfNotContains(_ element: Element) -> Bool {
        if contains(element) {
            return false
        } else {
            append(element)
            return true            
        }
    }
    
}
