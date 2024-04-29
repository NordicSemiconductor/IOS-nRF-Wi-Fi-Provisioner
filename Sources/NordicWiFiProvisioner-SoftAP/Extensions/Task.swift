//
//  Task.swift
//  NordicWiFiProvisioner-SoftAP
//
//  Created by Dinesh Harjani on 17/4/24.
//

import Foundation

public extension Task where Success == Never, Failure == Never {
    
    static func sleepFor(seconds: Int) async throws {
        try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
    }
}
