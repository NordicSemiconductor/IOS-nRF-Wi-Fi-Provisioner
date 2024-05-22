/*
* Copyright (c) 2022, Nordic Semiconductor
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
import os

/*
 let logger = Logger(
     subsystem: Bundle(for: ScannerViewModel.self).bundleIdentifier ?? "",
     category: "scanner.scanner-view-model"
 )
 */

struct Logger {
    enum Privacy {
        case `public`
        case `private`
    }
    
    let subsystem: String
    let category: String
    
    private func log(_ message: String, type: OSLogType = .default, privacy: Privacy = .public) {
        if case .private = privacy {
            os_log("%{private}s", log: OSLog(subsystem: subsystem, category: category), type: type, message)
        } else {
            os_log("%{public}s", log: OSLog(subsystem: subsystem, category: category), type: type, message)
        }
    }
    
    func debug(_ message: String, privacy: Privacy = .public) {
        log(message, type: .debug, privacy: privacy)
    }

    func info(_ message: String, privacy: Privacy = .public) {
        log(message, type: .info, privacy: privacy)
    }

    func error(_ message: String, privacy: Privacy = .public) {
        log(message, type: .error, privacy: privacy)
    }

    func fault(_ message: String, privacy: Privacy = .public) {
        log(message, type: .fault, privacy: privacy)
    }
    
    func `default`(_ message: String, privacy: Privacy = .public) {
        log(message, type: .default, privacy: privacy)
    }


}
