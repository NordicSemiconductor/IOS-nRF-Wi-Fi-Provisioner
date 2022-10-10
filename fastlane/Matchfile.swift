public class Matchfile: MatchfileProtocol {
    public var gitUrl: String { environmentVariable(get: "GIT_URL") }
    public var type: String { "appstore" } // The default type, can be: appstore, adhoc, enterprise or development
    public var appIdentifier: [String] { [environmentVariable(get: "DEVELOPER_APP_IDENTIFIER")] }
    public var readonly: Bool { true }
    
//     var appIdentifier: [String] { return ["tools.fastlane.app", "tools.fastlane.app2"] }
		// cat username:String { return "user@fastlane.tools" } // Your Apple Developer Portal username
}

// For all available options run `fastlane match --help`
// Remove the // in the beginning of the line to enable the other options
