//
//  ReadableError.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 19/07/2022.
//

import Foundation
import NordicWiFiProvisioner_BLE

/// Error with readable title and message ready to show for user
protocol ReadableError: Error {
    var title: String? { get }
    var message: String { get }
}

struct TitleMessageError: ReadableError {
    var title: String?
    var message: String
    
    var localizedDescription: String {
        message
    }
}

extension TitleMessageError {
    init(title: String, message: String) {
        self.title = title
        self.message = message
    }

    init(title: String, error: Error) {
        self.title = title
        self.message = error.localizedDescription
    }

    init(error: Error) {
        if let e = error as? ProvisionerError {
            self.init(provError: e)
        } else {
            self.init(title: "Error", error: error)
        }
    }
    
    private init(provError: ProvisionerError) {
        self.init(title: "Error", message: provError.localizedDescription)
    }
}

extension TitleMessageError: LocalizedError {
    var errorDescription: String? {
        if let title {
            return title + ": " + message
        } else {
            return message
        }
    }
}
