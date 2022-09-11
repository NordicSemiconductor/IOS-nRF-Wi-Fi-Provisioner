//
//  WiFiInfo.swift
//  
//
//  Created by Nick Kibysh on 27/07/2022.
//

import Foundation

extension WifiInfo: CustomDebugStringConvertible {
    var debugDescription: String {
        do {
            return try jsonString()
        } catch {
            return "WiFi info: \(String(data: ssid, encoding: .utf8) ?? "n/a")"
        }
    }
}
