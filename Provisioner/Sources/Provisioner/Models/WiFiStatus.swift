//
// Created by Nick Kibysh on 28/09/2022.
//

import Foundation

public enum WiFiStatus: CustomDebugStringConvertible {
    case disconnected
    case authentication
    case association
    case obtainingIp
    case connected
    case connectionFailed(ConnectionFailure)

    public enum ConnectionFailure {
        case authError
        case networkNotFound
        case timeout
        case failIp
        case failConn
        case unknown

        func toProto() -> ConnectionFailureReason? {
            switch self {
            case .authError:
                return .authError
            case .networkNotFound:
                return .networkNotFound
            case .timeout:
                return .timeout
            case .failIp:
                return .failIp
            case .failConn:
                return .failConn
            case .unknown:
                return nil // unknown is not supported by proto
            }
        }
    }

    public var debugDescription: String {
        switch self {
        case .disconnected: return "disconnected"
        case .authentication: return "authentication"
        case .association: return "association"
        case .obtainingIp: return "obtainingIp"
        case .connected: return "connected"
        case .connectionFailed(let reason): return "connectionFailed: \(reason)"
        }
    }

    public struct Service {
        public static let wifi = UUID(uuidString: "14387800-130c-49e7-b877-2881c89cb258")!

        public struct Characteristic {
            public static let version = UUID(uuidString: "14387801-130c-49e7-b877-2881c89cb258")!
            public static let controlPoint = UUID(uuidString: "14387802-130c-49e7-b877-2881c89cb258")!
            public static let dataOut = UUID(uuidString: "14387803-130c-49e7-b877-2881c89cb258")!
        }
    }
}

extension WiFiStatus {
    func toProto() -> ConnectionState? {
        switch self {
        case .disconnected:
            return .disconnected
        case .authentication:
            return .authentication
        case .association:
            return .association
        case .obtainingIp:
            return .obtainingIp
        case .connected:
            return .connected
        case .connectionFailed:
            return nil
        }
    }
}