//
// Created by Nick Kibysh on 04/09/2022.
//

import Foundation
import Provisioner
import os

class AccessPointListViewModel: ObservableObject {
    private let logger = Logger(subsystem: String(describing: AccessPointListViewModel.self), category: "AccessPointListViewModel")
    // MARK: - Constants
    let provisioner: Provisioner
    var accessPointSelection: AccessPointSelection

    // MARK: - Properties
    @Published(initialValue: []) var accessPoints: [AccessPoint]
    @Published(initialValue: false) var isScanning: Bool
    @Published(initialValue: nil) var selectedAccessPoint: AccessPoint? {
        didSet {
            guard let ap = selectedAccessPoint else {
                return
            }
            accessPointSelection.selectedAccessPoint = ap
            accessPointSelection.showAccessPointList = false
        }
    }

    // MARK: - Private Properties
    private var allAccessPoints: Set<AccessPoint> = [] {
        didSet {
            var aps: [AccessPoint] = []
            for ap in allAccessPoints {
                if let existing = aps.firstIndex(where: { $0.ssid == ap.ssid }) {
                    aps[existing].rssi = max(aps[existing].rssi, ap.rssi)
                } else {
                    aps.append(ap)
                }
            }
            accessPoints = aps.sorted(by: { $0.rssi > $1.rssi })
        }
    }

    init(provisioner: Provisioner, accessPointSelection: AccessPointSelection) {
        self.provisioner = provisioner
        self.accessPointSelection = accessPointSelection
    }

}

extension AccessPointListViewModel {

    func allChannels(for accessPoint: AccessPoint) -> [AccessPoint] {
        let array = Array(allAccessPoints).filter { $0.ssid == accessPoint.ssid }
        return array
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
                    self.allAccessPoints.insert(scanResult)
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
        }
    }

}