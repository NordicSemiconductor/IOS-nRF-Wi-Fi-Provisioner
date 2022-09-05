//
// Created by Nick Kibysh on 04/09/2022.
//

import Foundation
import Provisioner

class AccessPointListViewModel: ObservableObject {
    // MARK: - Constants
    let provisioner: Provisioner

    // MARK: - Properties
    @Published(initialValue: []) var accessPoints: [AccessPoint]
    @Published(initialValue: false) var isScanning: Bool
    @Published(initialValue: nil) var selectedAccessPoint: AccessPoint?

    // MARK: - Private Properties
    private var allAccessPoints: [AccessPoint] = [] {
        didSet {
            for ap in allAccessPoints {
                guard let existing = accessPoints.first(where: { $0.ssid == ap.ssid }) else {
                    accessPoints.append(ap)
                    continue
                }

                if existing.rssi < ap.rssi {
                    // replace existing with new one
                    let index = accessPoints.firstIndex(where: { $0.ssid == ap.ssid })!
                    accessPoints[index] = ap
                }
            }
        }
    }

    init(provisioner: Provisioner) {
        self.provisioner = provisioner
    }

}

extension AccessPointListViewModel {

    func allChannels(for accessPoint: AccessPoint) -> [AccessPoint] {
        return allAccessPoints.filter { $0.ssid == accessPoint.ssid }
    }

    func startScan() async {
        DispatchQueue.main.async {
            self.allAccessPoints.removeAll()
            self.isScanning = true
        }
        do {
            for try await scanResult in try await provisioner.startScan().values {
                print(scanResult.ssid)
                DispatchQueue.main.async {
                    self.allAccessPoints.append(scanResult)
                }
            }
            DispatchQueue.main.async {
                self.isScanning = false
            }
        } catch let e {
            print(e.localizedDescription)
            DispatchQueue.main.async {
                self.isScanning = false
            }
        }
    }

    func stopScan() async throws {
        try await provisioner.stopScan()
        DispatchQueue.main.async {
            self.isScanning = false
            self.allAccessPoints.removeAll()
        }
    }

}