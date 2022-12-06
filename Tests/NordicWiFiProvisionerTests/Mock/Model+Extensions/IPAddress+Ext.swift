//
// Created by Nick Kibysh on 21/11/2022.
//

import Foundation
import NordicWiFiProvisioner

extension IPAddress {
    static let ip1 = IPAddress(data: 0xff_ff_ff_ff.toData().suffix(4))! // 255.255.255.255
    static let ip2 = IPAddress(data: 0xc0_a8_01_01.toData().suffix(4))! // 192.168.1.1
    static let ip3 = IPAddress(data: 0x01_01_01_01.toData().suffix(4))!
    static let ip4 = IPAddress(data: 0x08_08_08_08.toData().suffix(4))!
}
