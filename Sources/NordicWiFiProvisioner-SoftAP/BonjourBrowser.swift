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
        if browser != nil {
            browser?.cancel()
            browser = nil
        }
        
        browser = NWBrowser(for: service.descriptor(), using: .discoveryParameters)
        delegate?.log("Warming Up Network Browser...", level: .debug)
        
        // Wait a couple of seconds for the connection to settle-in.
        try? await Task.sleepFor(seconds: 3)
        
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
                var netService: NetService?
                var txtRecord: NWTXTRecord?
                delegate?.log("Found \(results.count) results.", level: .debug)
                for result in results {
                    if case .service(let browserService) = result.endpoint, browserService.name == service.name {
                        netService = NetService(domain: browserService.domain, type: browserService.type, name: browserService.name)
                        if case .bonjour(let record) = result.metadata {
                            txtRecord = record
                            delegate?.log("Found TXT Record for \(service.name)", level: .debug)
                        } else {
                            delegate?.log("No TXT Record found", level: .info)
                        }
                        break
                    }
                }
                
                guard let netService else { return }
                
                if resolveIPAddress {
                    BonjourResolver.resolve(service: netService) { [weak self] result in
                        switch result {
                        case .success(let ipAddress):
                            self?.cachedIPAddresses[netService.name] = ipAddress
                            self?.delegate?.log("Cached IP ADDRESS \(ipAddress) for Service \(netService.name)", level: .debug)
                            timeoutTask.cancel()
                            continuation.resume(returning: txtRecord)
                        case .failure(let error):
                            timeoutTask.cancel()
                            self?.delegate?.log("IP Address Resolution Failed - Unable to cache IP address for Service \(netService.name) due to \(error.localizedDescription).", level: .fault)
                            continuation.resume(returning: txtRecord)
                        }
                    }
                    RunLoop.main.run(until: Date(timeIntervalSinceNow: 2.0))
                } else {
                    timeoutTask.cancel()
                    continuation.resume(returning: txtRecord)
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
