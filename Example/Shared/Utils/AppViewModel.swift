//
//  AppViewModel.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Dinesh Harjani on 16/2/24.
//

import Foundation
import SwiftUI
import iOS_Common_Libraries

// MARK: - AppViewModel

final class AppViewModel: ObservableObject {
    
    // MARK: Properties
    
    @AppStorage("introViewShown") var introViewShown: Bool = false
    /**
     Show start info on launch
     */
    @Published var showStartInfo: Bool = false
    private(set) var version: String = "Unknown Version"

    // MARK: Init
    
    init() {
        if CommandLine.arguments.contains("always-show-intro") {
            introViewShown = false
        }
        self.showStartInfo = !introViewShown
        self.version = Constant.appVersion(forBundleWithClass: Self.self)
    }
}
