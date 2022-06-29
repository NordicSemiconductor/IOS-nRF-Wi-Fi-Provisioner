//
//  File.swift
//  
//
//  Created by Nick Kibysh on 28/06/2022.
//

#if os(iOS)
import UIKit

extension UIColor {
    convenience init(rgba: RGBA) {
        self.init(red: rgba.r, green: rgba.g, blue: rgba.b, alpha: rgba.a)
    }
    
    convenience init(light: RGBA, dark: RGBA) {
        self.init { collection in
            collection.userInterfaceStyle == .dark
                ? UIColor(rgba: dark)
                : UIColor(rgba: light)
        }
    }
}
#endif
