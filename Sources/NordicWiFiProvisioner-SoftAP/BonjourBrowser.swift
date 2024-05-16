//
//  BonjourBrowser.swift
//  NordicWiFiProvisioner-SoftAP
//
//  Created by Dinesh Harjani on 29/4/24.
//

import Foundation
import Network

// MARK: - BonjourBrowser

final public class BonjourBrowser {
    
    // MARK: Properties
    
    private static let TIMEOUT_SECONDS = 10
    
    private var browser: NWBrowser?
    private lazy var cachedIPAddresses = [String: String]()
    
    public var delegate: ProvisionManager.Delegate?
    
    // MARK: Init
    
    public init() {}
    
    deinit {
        browser?.cancel()
        browser = nil
    }
    
    // MARK: API
    
    public func findBonjourService(_ service: BonjourService, preResolvingIPAddress resolveIPAddress: Bool = false) async throws -> NWTXTRecord? {
        
        delegate?.log("Warming Up Network Browser...", level: .debug)
        // Wait a couple of seconds for the connection to settle-in.
        try? await Task.sleepFor(seconds: 5)
        
        if browser != nil {
            browser?.cancel()
            browser = nil
        }
        
        browser = NWBrowser(for: service.descriptor(), using: .discoveryParameters)
        defer {
            delegate?.log("Cancelling Browser...", level: .debug)
            browser?.cancel()
        }
        return try await withCheckedThrowingContinuation { [weak browser] (continuation: CheckedContinuation<NWTXTRecord?, Error>) in
            let timeoutTask = Task { [delegate] in
                try await Task.sleepFor(seconds: Self.TIMEOUT_SECONDS)
                guard !Task.isCancelled else { return }
                delegate?.log("\(Self.TIMEOUT_SECONDS) second Timeout", level: .info)
                continuation.resume(throwing: BonjourError.serviceNotFound)
            }
            
            browser?.stateUpdateHandler = { [delegate] newState in
                switch newState {
                case .setup:
                    delegate?.log("Setting up connection", level: .info)
                case .ready:
                    delegate?.log("Network Browser ready", level: .debug)
                    delegate?.log("Waiting for search results..", level: .info)
                case .failed(let error):
                    delegate?.log("\(error.localizedDescription)", level: .error)
                    timeoutTask.cancel()
                    continuation.resume(throwing: error)
                case .cancelled:
                    delegate?.log("Stopped / Cancelled", level: .info)
                case .waiting(let nwError):
                    delegate?.log("Waiting for \(nwError.localizedDescription)?", level: .info)
                default:
                    break
                }
            }
            
            browser?.browseResultsChangedHandler = { [delegate] results, changes in
                delegate?.log("Found \(results.count) results.", level: .debug)
                for result in results {
                    switch result.endpoint {
                    case .service(let name, let type, let domain, _):
                        guard name == service.name else {
                            delegate?.log("Found \(name) Service. Skipping.", level: .debug)
                            continue
                        }
                        
                        // Cancel Timeout since we found a Service we're going to return.
                        timeoutTask.cancel()
                        let netService = NetService(domain: domain, type: type, name: name)
                        if resolveIPAddress {
                            BonjourResolver.resolve(service: netService) { [weak self] result in
                                switch result {
                                case .success(let ipAddress):
                                    self?.cachedIPAddresses[netService.name] = ipAddress
                                    self?.delegate?.log("Cached IP ADDRESS \(ipAddress) for Service \(netService.name)", level: .debug)
                                case .failure(let error):
                                    self?.delegate?.log("IP Address Resolution Failed - Unable to cache IP address for Service \(netService.name) due to \(error.localizedDescription).", level: .fault)
                                }
                            }
                            RunLoop.main.run(until: Date(timeIntervalSinceNow: 2.0))
                        }
                        
                        if case .bonjour(let record) = result.metadata {
                            delegate?.log("Found TXT Record for \(service.name)", level: .debug)
                            continuation.resume(returning: record)
                        } else {
                            delegate?.log("No TXT Record found", level: .info)
                            continuation.resume(returning: nil)
                        }
                    default:
                        continue
                    }
                }
            }
            
            delegate?.log("Starting Browser...", level: .debug)
            browser?.start(queue: .main)
        }
    }
    
    // MARK: IP Resolution
    
    public func resolveIPAddress(for service: BonjourService) async throws -> String {
        guard let cacheHit = cachedIPAddresses[service.name] else {
            delegate?.log("Cache Miss for Resolving \(service.name). Attempting to resolve again...",
                level: .fault)
            let resolvedIPAddress = try await BonjourResolver.resolve(service)
            return resolvedIPAddress
        }
        delegate?.log("Cache Hit for Resolving \(service.name)", level: .info)
        return cacheHit
    }
    
    public func clearCaches() {
        delegate?.log("Clearing Cached Resolved IP Addresses.",
            level: .debug)
        cachedIPAddresses.removeAll()
    }
}
