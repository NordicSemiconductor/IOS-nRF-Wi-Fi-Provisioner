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
    func appendIfNotContains(_ element: Element) -> Bool {
        if contains(element) {
            return false
        } else {
            append(element)
            return true            
        }
    }
    
    func appended(_ element: Element) -> [Element] {
        var newArr = self
        newArr.append(element)
        return newArr
    }
    
}
