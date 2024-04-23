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

// MARK: URL

private extension URL {
    static func ssid(ipAddress: String) -> URL {
        URL(string: "https://\(ipAddress)/prov/networks")!
    }
    
    static func prov(ipAddress: String) -> URL {
        URL(string: "https://\(ipAddress)/prov/configure")!
    }
}

// MARK: ProvisionManager

public class ProvisionManager {
    private let apSSID = "006825-nrf-wifiprov"
    private var browser: NWBrowser?
    
    public init() {}
    
    public enum ProvisionError: Error {
        case badResponse
        case cancelled
    }
    
    public struct HTTPError: Error, LocalizedError {
        let code: Int
        let responseData: Data?
        
        init(code: Int, responseData: Data?) {
            assert(code >= 400)
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
    
//    private var sessionConfig: URLSessionConfiguration {
//        let config = URLSessionConfiguration.default
//        config.waitsForConnectivity = false
//        config.requestCachePolicy = .reloadIgnoringLocalCacheData
//        return config
//    }
    
    private let logger = Logger(subsystem: "com.nordicsemi.NordicWiFiProvisioner-SoftAP", category: "SoftAP-Provisioner")
    private lazy var urlSession = URLSession(configuration: .default, delegate: NSURLSessionPinningDelegate.shared, delegateQueue: nil)
//    private lazy var urlSession = URLSession.shared
    
    public func connect() async throws {
        // Ask the user to switch to the Provisioning Device's Wi-Fi Network.
        let manager = NEHotspotConfigurationManager.shared
        let configuration = NEHotspotConfiguration(ssid: apSSID)
        
        try await switchWiFiEndpoint(using: manager, with: configuration)
    }
    
    public func findBonjourService(type: String, domain: String) async throws -> BonjourService {
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
            
            browser?.stateUpdateHandler = { newState in
                switch newState {
                case .setup:
                    print("Setting up connection")
                case .ready:
                    print("Ready?")
                case .failed(let error):
                    print(error.localizedDescription)
                    continuation.resume(throwing: error)
                case .cancelled:
                    print("Stopped / Cancelled")
                case .waiting(let nwError):
                    print("Waiting for \(nwError.localizedDescription)?")
                default:
                    break
                }
            }
            
            browser?.browseResultsChangedHandler = { results, changes in
                var netService: NetService?
                print("Found \(results.count) results.")
                for result in results {
                    if case .service(let service) = result.endpoint {
                        netService = NetService(domain: service.domain, type: service.type, name: service.name)
                        break
                    }
                }
                
                guard let netService else { return }
//                do {
//                    let a = try await BonjourResolver.resolve(BonjourService(netService: netService))
//                }
                BonjourResolver.resolve(service: netService) { result in
                    switch result {
                    case .success(let ipAddress):
                        let storedIP = ipAddress
                        print("STORED IP ADDRESS: \(ipAddress)")
//                        continuation.resume(returning: ipAddress)
                        continuation.resume(returning: BonjourService(netService: netService))
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
                RunLoop.main.run(until: Date(timeIntervalSinceNow: 2.0))
//                continuation.resume(returning: BonjourService(netService: netService))
            }
            logger.debug("Starting Browser...")
//            browser?.start(queue: .global())
            browser?.start(queue: .main)
        }
    }
    
    private func switchWiFiEndpoint(using manager: NEHotspotConfigurationManager,
                                    with configuration: NEHotspotConfiguration) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            manager.apply(configuration) { error in
                if let nsError = error as? NSError, nsError.code == 13 {
                    continuation.resume()
                    self.logger.info("Already Connected")
                } else if let error {
                    continuation.resume(throwing: error)
                    self.logger.error("\(error.localizedDescription)")
                } else {
                    continuation.resume()
                    self.logger.info("Connected")
                }
            }
        }
    }
    
    open func getScans(ipAddress: String) async throws -> [APWiFiScan] {
        let ssidsResponse = try await urlSession.data(from: .ssid(ipAddress: ipAddress))
//        session.invalidateAndCancel()
        if let resp = ssidsResponse.1 as? HTTPURLResponse, resp.statusCode >= 400 {
            throw HTTPError(code: resp.statusCode, responseData: ssidsResponse.0)
        }
        
        guard let result = try? ScanResults(serializedData: ssidsResponse.0) else {
            throw ProvisionError.badResponse
        }
        
        return result.results.compactMap { try? APWiFiScan(scanRecord: $0) }
    }
    
    open func provision(ipAddress: String, to accessPoint: APWiFiScan, with password: String?) throws {
        logger.debug(#function)
        
        var request = URLRequest(url: .prov(ipAddress: ipAddress))
        request.httpMethod = "POST"
        request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
//        request.addValue("application/x-protobuf", forHTTPHeaderField: "Content-Type")
        
//        request.httpMethod = "POST"
//        request.addValue("application/x-protobuf", forHTTPHeaderField: "Content-Type")
//        request.addValue("text/plain", forHTTPHeaderField: "Content-Type")
        
        var provisioningConfiguration = WifiConfig()
        
//        var info = WifiInfo()
////        info.ssid = accessPoint.ssid.data(using: .ascii) ?? Data()
//        info.ssid = Data(repeating: 0, count: 2)
//        info.bssid = Data(repeating: 0, count: 2)
////        info.bssid = Data(accessPoint.bssid) // accessPoint.bssid.data(using: .ascii) ?? Data()
////        info.bssid = accessPoint.info().bssid
//        info.channel = UInt32(accessPoint.channel)
//        info.band = Band.any // try Band(rawValue: accessPoint.band.rawValue)
//        info.auth = accessPoint.info().auth
//        provisioningConfiguration.wifi = info
        
        provisioningConfiguration.wifi = accessPoint.info()
        provisioningConfiguration.passphrase = (password ?? "").data(using: .utf8) ?? Data()
        let serialized = try provisioningConfiguration.serializedData()
        print(serialized)
        print(serialized.hexEncodedString())
        
        let deserialized = try WifiConfig(serializedData: serialized)
        print(deserialized)
        
        let httpData = Data()
//        let httpData = try! provisioningConfiguration.serializedData()
//        request.httpBody = try provisioningConfiguration.serializedData()
//        request.httpBody = Data()
        
        logger.debug("session.data(for: request)")
//            session.dataTask(with: request)
//            session.
//            session.data
        let task = urlSession.uploadTask(with: request, from: httpData) { data, response, error in
//        let task = urlSession.dataTask(with: request) { data, response, error in
            print(error)
            guard let urlResponse = (response as? HTTPURLResponse) else {
//                throw ProvisionError.badResponse
                print(ProvisionError.badResponse.localizedDescription)
                return
            }
            guard urlResponse.statusCode < 400 else {
                let error = HTTPError(code: urlResponse.statusCode, responseData: data)
                print(error.localizedDescription)
                return
            }
            print("Success?")
        }
        task.resume()
//        urlSession.dataTask(with: request) { data, response, error in
//            let response = try await urlSession.data(for: request)
//            guard let urlResponse = (response.1 as? HTTPURLResponse) else {
//                throw ProvisionError.badResponse
//            }
//            
//            guard urlResponse.statusCode < 400 else {
//                throw HTTPError(code: urlResponse.statusCode, responseData: response.0)
//            }
//        }
        
//        do {
//            
//            
//        } catch {
//            throw error
//        }
    }
}

internal extension Data {
  /// A hexadecimal string representation of the bytes.
  func hexEncodedString() -> String {
    let hexDigits = Array("0123456789abcdef".utf16)
    var hexChars = [UTF16.CodeUnit]()
    hexChars.reserveCapacity(count * 2)

    for byte in self {
      let (index1, index2) = Int(byte).quotientAndRemainder(dividingBy: 16)
      hexChars.append(hexDigits[index1])
      hexChars.append(hexDigits[index2])
    }

    return String(utf16CodeUnits: hexChars, count: hexChars.count)
  }
}
