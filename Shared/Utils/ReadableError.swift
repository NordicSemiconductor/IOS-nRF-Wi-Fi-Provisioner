//
//  ReadableError.swift
//  nRF-Wi-Fi-Provisioner
//
//  Created by Nick Kibysh on 19/07/2022.
//

import Foundation

/// Error with readable title and message ready to show for user
protocol ReadableError: Error {
    var title: String? { get }
    var message: String { get }
}

struct TitleMessageError: ReadableError {
    var title: String?
    var message: String
    
    var localizedDespcription: String {
        return message
    }
}
