//
//  CGRect+Ext.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 18/07/2022.
//

import UIKit

extension CGRect {
    var topLeft: CGPoint {
        CGPoint(x: minX, y: minY)
    }
    
    var topRight: CGPoint {
        CGPoint(x: maxX, y: minY)
    }
    
    var lowerLeft: CGPoint {
        CGPoint(x: minX, y: maxY)
    }
    
    var lowerRight: CGPoint {
        CGPoint(x: maxX, y: maxY)
    }
}
