/*
* Copyright (c) 2022, Nordic Semiconductor
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this
*    list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice, this
*    list of conditions and the following disclaimer in the documentation and/or
*    other materials provided with the distribution.
*
* 3. Neither the name of the copyright holder nor the names of its contributors may
*    be used to endorse or promote products derived from this software without
*    specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
* NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
* POSSIBILITY OF SUCH DAMAGE.
*/

import Foundation

/// WiFi Authentication Mode.
public enum AuthMode: Equatable {
    case open
    case wep
    case wpaPsk
    case wpa2Psk
    case wpaWpa2Psk
    case wpa2Enterprise
    case wpa3Psk
}

extension AuthMode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .open:
            return "Open"
        case .wep:
            return "WEP"
        case .wpaPsk:
            return "WPA-PSK"
        case .wpa2Psk:
            return "WPA2-PSK"
        case .wpaWpa2Psk:
            return "WPA/WPA2-PSK"
        case .wpa2Enterprise:
            return "WPA2-Enterprise"
        case .wpa3Psk:
            return "WPA3-PSK"
        }
    }
}

extension AuthMode: ProtoConvertible {
    var proto: Proto.AuthMode {
        switch self {
        case .open:
            return .open
        case .wep:
            return .wep
        case .wpaPsk:
            return .wpaPsk
        case .wpa2Psk:
            return .wpa2Psk
        case .wpaWpa2Psk:
            return .wpaWpa2Psk
        case .wpa2Enterprise:
            return .wpa2Enterprise
        case .wpa3Psk:
            return .wpa3Psk
        }
    }
    
    init(proto: Proto.AuthMode) {
        switch proto {
        case .open:
            self = .open
        case .wep:
            self = .wep
        case .wpaPsk:
            self = .wpaPsk
        case .wpa2Psk:
            self = .wpa2Psk
        case .wpaWpa2Psk:
            self = .wpaWpa2Psk
        case .wpa2Enterprise:
            self = .wpa2Enterprise
        case .wpa3Psk:
            self = .wpa3Psk
        }
    }
}
