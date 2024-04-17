//
//  BonjourResolver.swift
//  NordicWiFiProvisioner-SoftAP
//
//  Source: https://forums.developer.apple.com/forums/thread/673771
//  Quinn “The Eskimo!” @ Developer Technical Support @ Apple
//  let myEmail = "eskimo" + "1" + "@apple.com"
//  Created by Dinesh Harjani on 11/4/24.
//

import Foundation

// MARK: - BonjourResolver

public final class BonjourResolver: NSObject {
    
    // MARK: Public API
    
    public static func resolve(_ service: NetService) async throws -> String {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<String, Error>) in
            RunLoop.main.perform {
                BonjourResolver.resolve(service: service) { result in
                    switch result {
                    case .success(let ipAddress):
                        continuation.resume(returning: ipAddress)
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
            }
            print("Run Loop performed")
        }
    }
    
    public typealias CompletionHandler = (Result<String, ResolutionError>) -> Void
    
    @discardableResult
    public static func resolve(service: NetService, completionHandler: @escaping CompletionHandler) -> BonjourResolver {
        precondition(Thread.isMainThread)
        let resolver = BonjourResolver(service: service, completionHandler: completionHandler)
        resolver.start()
        return resolver
    }
    
    // MARK: Init
    
    private init(service: NetService, completionHandler: @escaping CompletionHandler) {
        // We want our own copy of the service because we’re going to set a
        // delegate on it but `NetService` does not conform to `NSCopying` so
        // instead we create a copy by copying each property.
        let copy = NetService(domain: service.domain, type: service.type, name: service.name)
        self.service = copy
        self.completionHandler = completionHandler
    }
    
    deinit {
        // If these fire the last reference to us was released while the resolve
        // was still in flight.  That should never happen because we retain
        // ourselves on `start`.
        assert(self.service == nil)
        assert(self.completionHandler == nil)
        assert(self.selfRetain == nil)
    }
    
    // MARK: Private
    
    private var service: NetService? = nil
    private var completionHandler: (CompletionHandler)? = nil
    private var selfRetain: BonjourResolver? = nil
    
    private func start() {
        precondition(Thread.isMainThread)
        guard let service else { fatalError() }
        service.delegate = self
        service.resolve(withTimeout: 5.0)
        // Form a temporary retain loop to prevent us from being deinitialised
        // while the resolve is in flight.  We break this loop in `stop(with:)`.
        selfRetain = self
    }
    
    private func stop() {
        stop(with: .failure(.stoppedbyUser))
    }
    
    private func stop(with result: Result<String, ResolutionError>) {
        precondition(Thread.isMainThread)
        self.service?.delegate = nil
        self.service?.stop()
        self.service = nil
        let completionHandler = self.completionHandler
        self.completionHandler = nil
        completionHandler?(result)
        
        selfRetain = nil
    }
}

// MARK: - NetServiceDelegate

extension BonjourResolver: NetServiceDelegate {
    
    public func netServiceDidResolveAddress(_ sender: NetService) {
        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        guard let data = sender.addresses?.first else {
            self.stop(with: .failure(.noAddressFound))
            return
        }
        // Source: https://stackoverflow.com/a/56525424
        data.withUnsafeBytes { ptr in
            guard let sockaddr_ptr = ptr.baseAddress?.assumingMemoryBound(to: sockaddr.self) else {
                self.stop(with: .failure(.unableToParseSocketAddress))
                return
            }
            
            let sockaddr = sockaddr_ptr.pointee
            guard getnameinfo(sockaddr_ptr, socklen_t(sockaddr.sa_len), &hostname, socklen_t(hostname.count), nil, 0, NI_NUMERICHOST) == 0 else {
                return
            }
        }
        stop(with: .success(String(cString: hostname)))
    }
    
    public func netService(_ sender: NetService, didNotResolve errorDict: [String: NSNumber]) {
        print(errorDict)
        let code = (errorDict[NetService.errorCode]?.intValue)
            .flatMap { NetService.ErrorCode.init(rawValue: $0) }
            ?? .unknownError
        let error = NSError(domain: NetService.errorDomain, code: code.rawValue, userInfo: nil)
        self.stop(with: .failure(.unableToResolve(reason: error.localizedDescription)))
    }
}

// MARK: - ResolutionError

public extension BonjourResolver {
    
    enum ResolutionError: Error, LocalizedError {
        case stoppedbyUser
        case unableToResolve(reason: String)
        case noAddressFound
        case unableToParseSocketAddress
    }
}
