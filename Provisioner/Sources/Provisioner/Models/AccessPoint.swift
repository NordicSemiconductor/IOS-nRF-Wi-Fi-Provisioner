//
//  File.swift
//  
//
//  Created by Nick Kibysh on 20/07/2022.
//

import Foundation

public struct AccessPoint: Identifiable {
    public var name: String
    public var id: UUID
    public var isOpen: Bool
    public var channel: Int
    public var rssi: Int

    init(name: String, id: UUID = UUID(), isOpen: Bool, channel: Int, rssi: Int) {
        self.name = name
        self.id = id
        self.isOpen = isOpen
        self.channel = channel
        self.rssi = rssi
    }
}
