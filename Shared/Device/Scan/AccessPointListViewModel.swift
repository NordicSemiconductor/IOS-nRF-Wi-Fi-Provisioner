//
// Created by Nick Kibysh on 04/09/2022.
//

import Combine
import Foundation
import Provisioner
import os

class AccessPointListViewModel: ObservableObject {
    private let logger = Logger(subsystem: String(describing: AccessPointListViewModel.self), category: "AccessPointListViewModel")
    private var cancellables = Set<AnyCancellable>()
    // MARK: - Constants
    let provisioner: Provisioner
    var accessPointSelection: AccessPointSelection
    
    // MARK: - Properties
    @Published(initialValue: []) var accessPoints: [AccessPoint]
    @Published(initialValue: false) var isScanning: Bool
    @Published(initialValue: nil) var selectedAccessPointId: String? {
        didSet {
            guard let apId = selectedAccessPointId else { return }
            self.selectedAccessPoint = allAccessPoints.first(where: { $0.id == apId })
        }
    }
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
            DispatchQueue.main.async {
                self.logger.debug("Assigned access points: \(self.allAccessPoints.count)")
                self.accessPoints = aps.sorted(by: { $0.ssid < $1.ssid })
            }
        }
    }
    
    init(provisioner: Provisioner, accessPointSelection: AccessPointSelection) {
        self.provisioner = provisioner
        self.accessPointSelection = accessPointSelection
    }
    
    func allChannels(for accessPoint: AccessPoint) -> [AccessPoint] {
        let array = Array(allAccessPoints)
            .filter { $0.ssid == accessPoint.ssid }
            .sorted { $0.rssi > $1.rssi }
        return array
    }
    
    func startScan() async {
        DispatchQueue.main.async { [unowned self] in
            self.allAccessPoints.removeAll()
            self.isScanning = true
            
            provisioner.startScan()
                .scan(Set<AccessPoint>(), { $0.inserted($1) })
                .assertNoFailure()
                .assign(to: \AccessPointListViewModel.allAccessPoints, on: self)
                .store(in: &cancellables)
        }
    }
    
    func stopScan() async throws {
        cancellables.removeAll()
        
        try await provisioner.stopScan()
        DispatchQueue.main.async {
            self.isScanning = false
        }
    }
    
}
