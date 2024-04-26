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
    
    private lazy var urlSession = URLSession(configuration: .default, delegate: NSURLSessionPinningDelegate.shared, delegateQueue: nil)
    private lazy var cachedIPAddresses = [String: String]()
    
    public var delegate: Delegate?
    
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
            log("Cancelling Browser...", level: .debug)
            browser?.cancel()
        }
        return try await withCheckedThrowingContinuation { [weak browser] (continuation: CheckedContinuation<BonjourService, Error>) in
            
            browser?.stateUpdateHandler = { [weak self] newState in
                switch newState {
                case .setup:
                    self?.log("Setting up connection", level: .info)
                case .ready:
                    self?.log("Ready?", level: .info)
                case .failed(let error):
                    self?.log("\(error.localizedDescription)", level: .error)
                    continuation.resume(throwing: error)
                case .cancelled:
                    self?.log("Stopped / Cancelled", level: .info)
                case .waiting(let nwError):
                    self?.log("Waiting for \(nwError.localizedDescription)?", level: .info)
                default:
                    break
                }
            }
            
            browser?.browseResultsChangedHandler = { [weak self] results, changes in
                var netService: NetService?
                self?.log("Found \(results.count) results.", level: .debug)
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
                        self?.log("Cached IP ADDRESS \(ipAddress) for Service \(netService.name)", level: .debug)
                        continuation.resume(returning: BonjourService(netService: netService))
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
                RunLoop.main.run(until: Date(timeIntervalSinceNow: 2.0))
            }
            log("Starting Browser...", level: .debug)
            browser?.start(queue: .main)
        }
    }
    
    private func switchWiFiEndpoint(using manager: NEHotspotConfigurationManager,
                                    with configuration: NEHotspotConfiguration) async throws {
        log("Clearing Cached Resolved IP Addresses due to Network Configuration Change.",
            level: .debug)
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
            log("Cache Miss for Resolving \(service.name). Attempting to resolve again...",
                level: .fault)
            let resolvedIPAddress = try await BonjourResolver.resolve(service)
            return resolvedIPAddress
        }
        log("Cache Hit for Resolving \(service.name)", level: .info)
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
        log(#function, level: .debug)
        
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
        log("Switching to \(accessPoint.ssid)...", level: .info)
        // Ask the user to switch to the Provisioned Network.
        let manager = NEHotspotConfigurationManager.shared
        let configuration = NEHotspotConfiguration(ssid: accessPoint.ssid, passphrase: passphrase, isWEP: accessPoint.authentication == .wep)
        try await switchWiFiEndpoint(using: manager, with: configuration)
        
        // Wait a couple of seconds for the firmware to make the connection switch.
        try? await Task.sleepFor(seconds: 2)
        
        _ = try await findBonjourService(type: "_http._tcp.", domain: "local", name: "wifiprov")
    }
    
    // MARK: Private
    
    private func log(_ line: String, level: OSLogType) {
        delegate?.log(line, level: level)
    }
}

// MARK: - ProvisionManager.Delegate

public extension ProvisionManager {
    
    protocol Delegate {
        func log(_ line: String, level: OSLogType)
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
