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
            accessPoints = aps.sorted(by: { $0.ssid < $1.ssid })
        }
    }
    
    init(provisioner: Provisioner, accessPointSelection: AccessPointSelection) {
        self.provisioner = provisioner
        self.accessPointSelection = accessPointSelection
    }
}

extension AccessPointListViewModel {
    
    func allChannels(for accessPoint: AccessPoint) -> [AccessPoint] {
        let array = Array(allAccessPoints)
            .filter { $0.ssid == accessPoint.ssid }
            .sorted { $0.channel < $1.channel }
        return array
    }
    
    func startScan() async {
        DispatchQueue.main.async {
            self.allAccessPoints.removeAll()
            self.isScanning = true
        }
        do {
            try await provisioner.startScan()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] completion in
                    guard let self = self else {
                        return
                    }
                    switch completion {
                    case .finished:
                        self.isScanning = false
                    case .failure(let error):
                        self.logger.error("failed to start scan: \(error.localizedDescription)")
                        self.isScanning = false
                    }
                } receiveValue: { [weak self] accessPoint in
                    guard let self = self else {
                        return
                    }
                    self.allAccessPoints.insert(accessPoint)
                }
                .store(in: &cancellables)
        } catch let e {
            print(e.localizedDescription)
            DispatchQueue.main.async {
                self.isScanning = false
            }
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
