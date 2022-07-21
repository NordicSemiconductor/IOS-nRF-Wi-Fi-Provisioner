import Foundation
import AsyncBluetooth

public class Provisioner {
    enum Error: Swift.Error {
        case wifiServiceNotFound
    }
    
    public static let WiFi_Provision_Service = UUID(uuidString: "14387800-130c-49e7-b877-2881c89cb258")!
    
    public let deviceID: UUID
    
    public init(deviceID: UUID) {
        self.deviceID = deviceID
    }
    
    public func parseScanData(_ scanData: ScanData) -> ScanDataInfo {
        let advData = AdvertisementData(scanData.advertisementData)
        print(advData)
        return ScanDataInfo()
    }
    
}
 
