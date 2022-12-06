//
//  Set+Ext.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 03/10/2022.
//

import Foundation

extension Set {
    func inserted(_ element: Element) -> Set<Element> {
        var set = self
        set.insert(element)
        return set 
    }
}
