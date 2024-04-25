//
//  ProvisionManager.swift
//  NordicWiFiProvisioner-SoftAP
//
//  Created by Nick Kibysh on 12/02/2024.
//

import Foundation
import Network
import NetworkExtension
import OSLog
import SwiftProtobuf

// MARK: ProvisionManager

public class ProvisionManager {
    private let apSSID = "006825-nrf-wifiprov"
    private var browser: NWBrowser?
    
    public init() {}
    
    private let logger = Logger(subsystem: "com.nordicsemi.NordicWiFiProvisioner-SoftAP", category: "SoftAP-Provisioner")
    private lazy var urlSession = URLSession(configuration: .default, delegate: NSURLSessionPinningDelegate.shared, delegateQueue: nil)
    private lazy var cachedIPAddresses = [String: String]()
    
    public func connect() async throws {
        // Ask the user to switch to the Provisioning Device's Wi-Fi Network.
        let manager = NEHotspotConfigurationManager.shared
        let configuration = NEHotspotConfiguration(ssid: apSSID)
        try await switchWiFiEndpoint(using: manager, with: configuration)
    }
    
    public func findBonjourService(type: String, domain: String, name: String) async throws -> BonjourService {
        // Wait a couple of seconds for the connection to settle-in.
        try? await Task.sleepFor(seconds: 2)
        
        if browser != nil {
            browser?.cancel()
            browser = nil
        }
        browser = NWBrowser(for: .bonjour(type: type, domain: domain),
                            using: .discoveryParameters)
        defer {
            print("Cancelling Browser...")
            browser?.cancel()
        }
        return try await withCheckedThrowingContinuation { [weak browser] (continuation: CheckedContinuation<BonjourService, Error>) in
            
            browser?.stateUpdateHandler = { [logger] newState in
                switch newState {
                case .setup:
                    logger.info("Setting up connection")
                case .ready:
                    logger.info("Ready?")
                case .failed(let error):
                    logger.info("\(error.localizedDescription)")
                    continuation.resume(throwing: error)
                case .cancelled:
                    logger.info("Stopped / Cancelled")
                case .waiting(let nwError):
                    logger.info("Waiting for \(nwError.localizedDescription)?")
                default:
                    break
                }
            }
            
            browser?.browseResultsChangedHandler = { [logger] results, changes in
                var netService: NetService?
                logger.debug("Found \(results.count) results.")
                for result in results {
                    if case .service(let service) = result.endpoint, service.name == name {
                        netService = NetService(domain: service.domain, type: service.type, name: service.name)
                        break
                    }
                }
                
                guard let netService else { return }
                // Resolve IP Address here or else, if we do it later, it'll fail.
                BonjourResolver.resolve(service: netService) { [weak self] result in
                    switch result {
                    case .success(let ipAddress):
                        self?.cachedIPAddresses[netService.name] = ipAddress
                        logger.debug("Cached IP ADDRESS \(ipAddress) for Service \(netService.name)")
                        continuation.resume(returning: BonjourService(netService: netService))
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
                RunLoop.main.run(until: Date(timeIntervalSinceNow: 2.0))
            }
            logger.debug("Starting Browser...")
            browser?.start(queue: .main)
        }
    }
    
    private func switchWiFiEndpoint(using manager: NEHotspotConfigurationManager,
                                    with configuration: NEHotspotConfiguration) async throws {
        logger.debug("Clearing Cached Resolved IP Addresses due to Network Configuration Change.")
        cachedIPAddresses.removeAll()
        
        do {
            try await manager.apply(configuration)
        } catch {
            let nsError = error as NSError
            guard nsError.domain == NEHotspotConfigurationErrorDomain,
                  let configurationError = NEHotspotConfigurationError(rawValue: nsError.code) else {
                throw error
            }
            
            switch configurationError {
            case .alreadyAssociated, .pending:
                // swallow Error.
                break
            default:
                throw error
            }
        }
    }
    
    public func resolveIPAddress(for service: BonjourService) async throws -> String {
        guard let cacheHit = cachedIPAddresses[service.name] else {
            self.logger.warning("Cache Miss for Resolving \(service.name). Attempting to resolve again...")
            let resolvedIPAddress = try await BonjourResolver.resolve(service)
            return resolvedIPAddress
        }
        self.logger.info("Cache Hit for Resolving \(service.name)")
        return cacheHit
    }
    
    public func getScans(ipAddress: String) async throws -> [APWiFiScan] {
        let ssidsResponse = try await urlSession.data(from: .ssid(ipAddress: ipAddress))
        if let response = ssidsResponse.1 as? HTTPURLResponse, response.statusCode >= 400 {
            throw HTTPError(code: response.statusCode, responseData: ssidsResponse.0)
        }
        
        guard let result = try? ScanResults(serializedData: ssidsResponse.0) else {
            throw ProvisionError.badResponse
        }
        
        return result.results.compactMap { try? APWiFiScan(scanRecord: $0) }
    }
    
    public func provision(ipAddress: String, to accessPoint: APWiFiScan, with password: String?) async throws {
        logger.debug(#function)
        
        var request = URLRequest(url: .prov(ipAddress: ipAddress))
        request.httpMethod = "POST"
        request.addValue("application/x-protobuf", forHTTPHeaderField: "Content-Type")
        
        var provisioningConfiguration = WifiConfig()
        provisioningConfiguration.wifi = accessPoint.info()
        provisioningConfiguration.passphrase = (password ?? "").data(using: .utf8) ?? Data()
        request.httpBody = try! provisioningConfiguration.serializedData()
        
        let provisionResponse = try await urlSession.data(for: request)
        if let response = provisionResponse.1 as? HTTPURLResponse, response.statusCode >= 400 {
            throw HTTPError(code: response.statusCode, responseData: provisionResponse.0)
        }
    }
    
    public func verifyProvisioning(to accessPoint: APWiFiScan, with passphrase: String) async throws {
        self.logger.info("Switching to \(accessPoint.ssid)...")
        // Ask the user to switch to the Provisioned Network.
        let manager = NEHotspotConfigurationManager.shared
        let configuration = NEHotspotConfiguration(ssid: accessPoint.ssid, passphrase: passphrase, isWEP: accessPoint.authentication == .wep)
        try await switchWiFiEndpoint(using: manager, with: configuration)
        
        // Wait a couple of seconds for the firmware to make the connection switch.
        try? await Task.sleepFor(seconds: 2)
        
        _ = try await findBonjourService(type: "_http._tcp.", domain: "local", name: "wifiprov")
    }
}

// MARK: - ProvisionManager.ProvisionError

extension ProvisionManager {
    
    public enum ProvisionError: Error {
        case badResponse
        case cancelled
    }
}
 
// MARK: - ProvisionManager.HTTPError

extension ProvisionManager {
    
    public struct HTTPError: Error, LocalizedError {
        let code: Int
        let responseData: Data?
        
        init(code: Int, responseData: Data?) {
            self.code = code
            self.responseData = responseData
        }
        
        public var errorDescription: String? {
            if let responseData, let message = String(data: responseData, encoding: .utf8), !message.isEmpty {
                return "\(code): \(message)"
            } else {
                return "\(code)"
            }
        }
    }
}

// MARK: URL

private extension URL {
    static func ssid(ipAddress: String) -> URL {
        URL(string: "https://\(ipAddress)/prov/networks")!
    }
    
    static func prov(ipAddress: String) -> URL {
        URL(string: "https://\(ipAddress)/prov/configure")!
    }
}
