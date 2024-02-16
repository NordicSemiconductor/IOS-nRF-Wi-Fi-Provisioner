//
//  AppViewModel.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Dinesh Harjani on 16/2/24.
//

import Foundation
import SwiftUI

final class AppViewModel: ObservableObject {
    
    @AppStorage("dontShowAgain") var dontShowAgain: Bool = false
    /**
     Show start info on first launch
     */
    @Published var showStartInfo: Bool = false

    init() {
        self.showStartInfo = !dontShowAgain
    }
}
