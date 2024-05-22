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

/// A struct that contains all the information about the device status.
///
/// All the fields are optional.
public struct DeviceStatus {
    public var state: ConnectionState?
    public var provisioningInfo: WifiInfo?
    public var connectionInfo: ConnectionInfo?
    public var scanInfo: ScanParams?
    
    public init(state: ConnectionState? = nil, provisioningInfo: WifiInfo? = nil, connectionInfo: ConnectionInfo? = nil, scanInfo: ScanParams? = nil) {
        self.state = state
        self.provisioningInfo = provisioningInfo
        self.connectionInfo = connectionInfo
        self.scanInfo = scanInfo
    }
}

extension DeviceStatus: ProtoConvertible {
    init(proto: Proto.DeviceStatus) {
        self.state = proto.hasState ? ConnectionState(proto: proto.state) : nil
        self.provisioningInfo = proto.hasProvisioningInfo ? WifiInfo(proto: proto.provisioningInfo) : nil
        self.connectionInfo = proto.hasProvisioningInfo ? ConnectionInfo(proto: proto.connectionInfo) : nil
        self.scanInfo = proto.hasScanInfo ? ScanParams(proto: proto.scanInfo) : nil
    }
    
    var proto: Proto.DeviceStatus {
        var proto = Proto.DeviceStatus()
        self.state.map { proto.state = $0.proto }
        self.provisioningInfo.map { proto.provisioningInfo = $0.proto }
        self.connectionInfo.map { proto.connectionInfo = $0.proto }
        self.scanInfo.map { proto.scanInfo = $0.proto }
        return proto
    }
}
