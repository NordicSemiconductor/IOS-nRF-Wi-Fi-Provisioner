import Foundation

public class Provisioner {
    enum Error: Swift.Error {
        case wifiServiceNotFound
    }
    
    public static let WiFi_Provision_Service = "14387800-130c-49e7-b877-2881c89cb258"
    
    public let deviceID: UUID
    
    public init(deviceID: UUID) {
        self.deviceID = deviceID
    }
    
    
}
 
