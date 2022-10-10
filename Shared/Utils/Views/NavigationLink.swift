//
// Created by Nick Kibysh on 19/09/2022.
//

import SwiftUI

extension NavigationLink {
    @ViewBuilder
    public func deviceAdoptiveDetail() -> some View {
        // for iPad call isDetailLink(true)
        // for iPhone call isDetailLink(false)
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.isDetailLink(true)
        } else {
            self.isDetailLink(false)
        }
        #endif
    }
}
