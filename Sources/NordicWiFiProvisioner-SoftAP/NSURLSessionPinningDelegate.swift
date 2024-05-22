/*
* Copyright (c) 2024, Nordic Semiconductor
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification,
* are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this
*    list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice, this
*    list of conditions and the following disclaimer in the documentation and/or
*    other materials provided with the distribution.
*
* 3. Neither the name of the copyright holder nor the names of its contributors may
*    be used to endorse or promote products derived from this software without
*    specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
* IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
* INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
* NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
* PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
* WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
* POSSIBILITY OF SUCH DAMAGE.
*/

import Foundation
import NetworkExtension
import OSLog

// MARK: - NSURLSessionPinningDelegate

final class NSURLSessionPinningDelegate: NSObject, URLSessionDelegate {
    
    // MARK: Private Properties
    
    private let certificateURL: URL
    
    private lazy var logger = Logger(subsystem: "com.nordicsemi.NordicWiFiProvisioner-SoftAP",
                                     category: "NSURLSessionPinningDelegate")
    
    // MARK: Init
    
    init(certificateURL: URL) {
        self.certificateURL = certificateURL
        super.init()
    }
    
    // MARK: URLSessionDelegate
    
    func urlSession(_ session: URLSession,
                      didReceive challenge: URLAuthenticationChallenge,
                      completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                Task {
                    let result = await shouldAllowHTTPSConnection(trust: serverTrust)
                    if result {
                        completionHandler(URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: serverTrust))
                    } else {
                        completionHandler(URLSession.AuthChallengeDisposition.cancelAuthenticationChallenge, nil)
                    }
                }
            }
        }
    }

    func shouldAllowHTTPSConnection(chain: [SecCertificate]) async throws -> Bool {
        guard let certData = try? Data(contentsOf: certificateURL),
              let anchor = SecCertificateCreateWithData(nil, certData as NSData) else {
            fatalError()
        }
        
        let policy = SecPolicyCreateBasicX509()
        let trust = try secCall { SecTrustCreateWithCertificates(chain as NSArray, policy, $0) }
        let err = SecTrustSetAnchorCertificates(trust, [anchor] as NSArray)
        guard err == errSecSuccess else {
            logger.error("SecTrustSetAnchorCertificates Error: \(err)")
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(err), userInfo: nil)
        }

        var secresult: CFError? = nil
        let status = SecTrustEvaluateWithError(trust, &secresult)
        return status
    }

    func shouldAllowHTTPSConnection(trust: SecTrust) async -> Bool {
        guard let chain = SecTrustCopyCertificateChain(trust) as? [SecCertificate] else { return false }
        do {
            return try await shouldAllowHTTPSConnection(chain: chain)
        } catch {
            logger.error("shouldAllowHTTPSConnection Error: \(error.localizedDescription)")
            return false
        }
    }

    func secCall<Result>(_ body: (_ resultPtr: UnsafeMutablePointer<Result?>) -> OSStatus) throws -> Result {
        var result: Result? = nil
        let err = body(&result)

        guard err == errSecSuccess else {
            logger.error("secCall Error: \(err)")
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(err), userInfo: nil)
        }
        return result!
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        guard let error else { return }
        logger.debug("\(#function)")
        logger.error("Error: \(error.localizedDescription)")
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        logger.debug("\(#function)")
        logger.debug("\(session)")
    }
}
