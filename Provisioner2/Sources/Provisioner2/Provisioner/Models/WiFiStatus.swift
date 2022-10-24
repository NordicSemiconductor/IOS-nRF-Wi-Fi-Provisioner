//
// Created by Nick Kibysh on 18/10/2022.
//

import Foundation

public enum WiFiStatus: String, Codable {
    case connected
    case disconnected
    case connecting
    case error
}
