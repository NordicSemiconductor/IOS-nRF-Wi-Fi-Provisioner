//
//  StatusIndicatorView.swift
//  nRF-Wi-Fi-Provisioner (iOS)
//
//  Created by Nick Kibysh on 10/11/2022.
//

import SwiftUI
import Provisioner2

struct StatusIndicatorView: View {
    let status: ConnectionState?
    let forceProgress: Bool
    
    init(status: ConnectionState?, forceProgress: Bool = false) {
        self.status = status
        self.forceProgress = forceProgress
    }
    
    var body: some View {
        switch (status, forceProgress) {
        case (_, true):
            ProgressView()
        case (.connected?, _):
            Image(systemName: "checkmark")
        case (.association?, false): ProgressView()
        case (.authentication?, false):  ProgressView()
        case (.obtainingIp?, false):  ProgressView()
        case (.connectionFailed, _):
            Image(systemName: "info.circle")
        default: Text("")
        }
    }
}

#if DEBUG
private struct Raw: View {
    let status: ConnectionState?
    let forceProgress: Bool
    
    init(status: ConnectionState?, forceProgress: Bool = false) {
        self.status = status
        self.forceProgress = forceProgress
    }
    
    var body: some View {
        HStack {
            Text(status?.description ?? "n/a")
            Spacer()
            StatusIndicatorView(status: status, forceProgress: forceProgress)
        }
    }
}

struct StatusIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            Raw(status: .connected)
            Raw(status: .disconnected)
            Raw(status: .disconnected, forceProgress: true)
            Raw(status: .obtainingIp)
            Raw(status: .connectionFailed(.failConn))
            Raw(status: .association)
            Raw(status: .authentication)
        }
    }
}
#endif
