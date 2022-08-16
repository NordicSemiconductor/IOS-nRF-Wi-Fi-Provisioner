// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//

import Foundation

let appIdKey = "ASC_KEY_ID"
let issuerIdKey = "ASC_ISSUER_ID"
let privateKeyId = "ASC_PRIVATE_KEY"

let iosTarget = "nRF-Wi-Fi-Provisioner (iOS)"

class Fastfile: LaneFile {
    func loadAPIKey() {
        desc("Load the ASC API key")

        let keyId = environmentVariable(get: "ASC_KEY_ID")
        let issuerId = environmentVariable(get: "ASC_ISSUER_ID")
        let keyContent = environmentVariable(get: "ASC_PRIVATE_KEY")
        
        appStoreConnectApiKey(
            keyId: keyId,
            issuerId: issuerId,
            keyContent: .userDefined(keyContent),
            isKeyContentBase64: true,
            inHouse: false
        )
    }

    func incrementTestflightBuildNumber() {
        let currentVersion = getVersionNumber(target: .userDefined(iosTarget))
        let buildNumber = latestTestflightBuildNumber(
            appIdentifier: "com.nordicsemi.nRF-Wi-Fi-Provisioner",
            version: .userDefined(currentVersion)
        )
        
        incrementBuildNumber(buildNumber: .userDefined("\(buildNumber + 1)"))
    }
    
    func betaLane() {
        desc("Increment build number, build app and deploy to TestFlight")
        
        let keychainName = environmentVariable(get: "TEMP_KEYCHAIN_USER")
        let keychainPassword = environmentVariable(get: "TEMP_KEYCHAIN_PASSWORD")
        createTmpKeychain(name: keychainName, password: keychainPassword)
        loadAPIKey()

        incrementTestflightBuildNumber()
        setAutomaticSignin(false)

        match(
            keychainName: keychainName,
            keychainPassword: .userDefined(keychainPassword)
        )
        
        gym(
            scheme: "nRF-Wi-Fi-Provisioner (iOS)",
            configuration: "Release",
            exportOptions: .userDefined(
                [
                    "method" : "app-store",
                    "provisioningProfiles" : [
                        "com.nordicsemi.nRF-Wi-Fi-Provisioner" : "match AppStore com.nordicsemi.nRF-Wi-Fi-Provisioner"
                    ],
                    "compileBitcode" : true
                ]
            ),
            xcodebuildFormatter: "xcpretty"
        )

//        buildIosApp(xcodebuildFormatter: "xcpretty")
//        uploadToTestflight()
//        setAutomaticSignin(true)
    }
}

extension Fastfile {
    func setAutomaticSignin(_ enabled: Bool) {
        automaticCodeSigning(
            path: "nRF-Wi-Fi-Provisioner.xcodeproj",
            useAutomaticSigning: .userDefined(enabled),
            teamId: .userDefined(environmentVariable(get: "APP_STORE_CONNECT_TEAM_ID")),
            targets: .userDefined([iosTarget]),
            codeSignIdentity: "iPhone Distribution",
            profileName: "match AppStore com.nordicsemi.nRF-Wi-Fi-Provisioner",
//                    .userDefined(
//                getProvisioningProfile(
//                    appIdentifier: environmentVariable(get: "DEVELOPER_APP_IDENTIFIER")
//                )
//            ),
            bundleIdentifier: .userDefined(environmentVariable(get: "DEVELOPER_APP_IDENTIFIER")))
    }
    
    func createTmpKeychain(name: String, password: String) {
        desc("Create a keychain")
        let filePath = "~/Library/Keychains/\(name)-db"
        if FileManager.default.fileExists(atPath: filePath) {
            deleteKeychain(keychainPath: OptionalConfigValue(stringLiteral: filePath))
        }
        
        createKeychain(
            name: .userDefined(name),
            password: password,
            unlock: true,
            timeout: 0
        )
        
//        createKeychain(
//            name: .userDefined(name),
//            path: .userDefined(filePath),
//            password: password,
//            unlock: true,
//            timeout: 0
//        )

    }
}
