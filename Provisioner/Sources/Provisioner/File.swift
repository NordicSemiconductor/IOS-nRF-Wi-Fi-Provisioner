import Foundation
import CoreBluetoothMock

struct AdvertisementData {
    
    // MARK: - Properties
    
    let localName: String? // CBAdvertisementDataLocalNameKey
    let manufacturerData: Data? // CBAdvertisementDataManufacturerDataKey
    let serviceData: [CBMUUID : Data]? // CBAdvertisementDataServiceDataKey
    let serviceUUIDs: [CBMUUID]? // CBAdvertisementDataServiceUUIDsKey
    let overflowServiceUUIDs: [CBMUUID]? // CBAdvertisementDataOverflowServiceUUIDsKey
    let txPowerLevel: Int? // CBAdvertisementDataTxPowerLevelKey
    let isConnectable: Bool? // CBAdvertisementDataIsConnectable
    let solicitedServiceUUIDs: [CBMUUID]? // CBAdvertisementDataSolicitedServiceUUIDsKey
    
    // MARK: - Init
    
    init() {
        self.init([:])
    }
    
    init(_ advertisementData: [String : Any]) {
        localName = advertisementData[CBMAdvertisementDataLocalNameKey] as? String
        manufacturerData = advertisementData[CBMAdvertisementDataManufacturerDataKey] as? Data
        serviceData = advertisementData[CBMAdvertisementDataServiceDataKey] as? [CBMUUID : Data]
        serviceUUIDs = advertisementData[CBMAdvertisementDataServiceUUIDsKey] as? [CBMUUID]
        overflowServiceUUIDs = advertisementData[CBMAdvertisementDataOverflowServiceUUIDsKey] as? [CBMUUID]
        txPowerLevel = (advertisementData[CBMAdvertisementDataTxPowerLevelKey] as? NSNumber)?.intValue
        isConnectable = (advertisementData[CBMAdvertisementDataIsConnectable] as? NSNumber)?.boolValue
        solicitedServiceUUIDs = advertisementData[CBMAdvertisementDataSolicitedServiceUUIDsKey] as? [CBMUUID]
    }
}

// MARK: - Debug

#if DEBUG
extension AdvertisementData {
    static var connectableMock: AdvertisementData {
        AdvertisementData(
            [
                CBMAdvertisementDataLocalNameKey : "iPhone 13",
                CBMAdvertisementDataIsConnectable : true as NSNumber
            ]
        )
    }
    
    static var unconnectableMock: AdvertisementData {
        AdvertisementData(
            [
                CBMAdvertisementDataLocalNameKey : "iPhone 14",
                CBMAdvertisementDataIsConnectable : false as NSNumber
            ]
        )
    }
}
#endif
