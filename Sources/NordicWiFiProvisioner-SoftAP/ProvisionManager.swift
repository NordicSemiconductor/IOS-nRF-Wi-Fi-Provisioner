//
//  File.swift
//  
//
//  Created by Nick Kibysh on 12/02/2024.
//

import Foundation
import NetworkExtension

open class ProvisionManager {
    public init() {}

    open func connect() async throws {
        let manager = NEHotspotConfigurationManager.shared
        let configuration = NEHotspotConfiguration(ssid: "mobileappsrules")
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            manager.apply(configuration) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
