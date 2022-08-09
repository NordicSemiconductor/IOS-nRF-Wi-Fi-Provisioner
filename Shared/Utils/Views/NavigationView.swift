//
//  NavigationView.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 09/08/2022.
//

import SwiftUI
import NordicStyle

extension NavigationView {
    
    func setSingleColumnNavigationViewStyle() -> some View {
        self
        #if os(iOS)
            .navigationViewStyle(StackNavigationViewStyle())
        #endif
    }
    
     func setupNavBarBackground() -> NavigationView {
         #if os(iOS)
         let appearance = UINavigationBarAppearance()
         let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white
         ]
         appearance.titleTextAttributes = attributes
         appearance.largeTitleTextAttributes = attributes
         appearance.backgroundColor = UIColor(Color.navigationBarBackground)
         UINavigationBar.appearance().compactAppearance = appearance
         UINavigationBar.appearance().standardAppearance = appearance
         UINavigationBar.appearance().scrollEdgeAppearance = appearance
         #endif
         return self
    }
}
