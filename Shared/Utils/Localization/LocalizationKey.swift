//
//  LocalizationKey.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 30/06/2022.
//

import Foundation

// Protocol for fast localization
protocol LocalizationKey {
    var localized: String { get }
}

// Enum with localization keys
enum LocalizationKeys: String, LocalizationKey {
    case introText = "INTRO_TEXT"
    case startProvisiningBtn="START_PROVISIONING_BTN"

    var localized: String {
        return NSLocalizedString(self.rawValue, comment: "")
    }
}
