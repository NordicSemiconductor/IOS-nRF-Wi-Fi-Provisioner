//
//  AppViewModel.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Dinesh Harjani on 16/2/24.
//

import Foundation
import SwiftUI
import Markdown

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
        self.showStartInfo = !introViewShown
        self.version = readVersion()
    }
    
    // MARK: Private
    
    private func readVersion() -> String {
        // Read the version from the Info.plist.
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        // Read the build number from the Info.plist.
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        return "\(version) (Build #\(build))"
    }
}
