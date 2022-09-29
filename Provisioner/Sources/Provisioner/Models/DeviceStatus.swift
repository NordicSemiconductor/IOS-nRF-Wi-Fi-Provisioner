//
// Created by Nick Kibysh on 28/09/2022.
//

import Foundation

/*
 message DeviceStatus {
   // The current state of the Wifi connection.
   optional ConnectionState state = 1; /// DONE!
   
   // Parameters:

   // The network information if provisioned to a network.
   // This can be set even if connection failed.
   optional ConnectionInfo info            = 10; /// Done wf info, not IP V 4
   // The failure reason is set when the state is CONNECTION_FAILED.
   optional ConnectionFailureReason reason = 11;
   // Set if the device is scanning.
   // The period_ms contains remaining scanning period.
   optional ScanParams scan_state          = 12;
 }

 */

// Response for 'getStatus' request
public struct WiFiDeviceStatus {
    let wifiStatus: ConnectionState?
    let wifiInfo: WifiInfo?
    let wifiFailureReason: ConnectionFailureReason?
    
    public var connectedAccessPoint: AccessPoint? {
        wifiInfo.map { AccessPoint(wifiInfo: $0, RSSI: 0) }
    }
    
    public var connectionStatus: WiFiStatus {
        wifiStatus?.toPublicStatus(withReason: wifiFailureReason) ?? .disconnected
    }
    
    init(deviceStatus: DeviceStatus) {
        self.wifiStatus = deviceStatus.state
        self.wifiInfo = deviceStatus.provisioningInfo
        self.wifiFailureReason = nil 
    }
    
    #if DEBUG
    public init(accessPoint: AccessPoint?, connectionStatus: WiFiStatus?) {
        self.wifiInfo = accessPoint?.wifiInfo
        self.wifiStatus = connectionStatus?.toProto()
        if let status = connectionStatus, case .connectionFailed(let reason) = status {
            self.wifiFailureReason = reason.toProto()
        } else {
            self.wifiFailureReason = nil
        }
    }
    #endif
    
}
