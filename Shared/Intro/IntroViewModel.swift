//
// Created by Nick Kibysh on 12/09/2022.
//

import SwiftUI
import Markdown

class IntroViewModel: ObservableObject {
    @Published var image: String = "nRF70-Series-nobg"
    @Published(initialValue: []) var markdown: [String]
    @Published var version: String = ""
    @AppStorage("dontShowAgain") var dontShowAgain: Bool = false

    func readInfo() throws {
        markdown = try readMarkdown()
        version = try readVersion()
    }

    private func readMarkdown() throws -> [String] {
        let dataAsset = NSDataAsset(name: "IntroText")!
        return String(data: dataAsset.data, encoding: .utf8)!
                .split(separator: "\n")
                .map { String($0) }
    }

    private func readVersion() throws -> String {
        // Read the version from the Info.plist.
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        // Read the build number from the Info.plist.
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""

        return "\(version) (\(build))"
    }
}

