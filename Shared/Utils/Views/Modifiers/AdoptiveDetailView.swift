//
// Created by Nick Kibysh on 19/09/2022.
//

import SwiftUI

struct AdoptiveDetailView: ViewModifier {
    func body(content: Content) -> some View {
        // do not apply detail view on iPad
        if UIDevice.current.userInterfaceIdiom == .pad {
            content
        } else {
            content
                .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}
