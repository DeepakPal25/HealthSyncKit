import HealthKit

/// The authorization state for a single health data type.
public enum AuthorizationStatus: String, Sendable {
    case notDetermined
    case denied
    case authorized

    init(_ hkStatus: HKAuthorizationStatus) {
        switch hkStatus {
        case .notDetermined:    self = .notDetermined
        case .sharingDenied:    self = .denied
        case .sharingAuthorized: self = .authorized
        @unknown default:       self = .notDetermined
        }
    }

    public var isAuthorized: Bool { self == .authorized }
}

/// Result returned after requesting authorization for a set of permissions.
public struct AuthorizationResult: Sendable {
    public let statuses: [HealthPermission: AuthorizationStatus]

    public var allGranted: Bool {
        statuses.values.allSatisfy { $0.isAuthorized }
    }

    public var denied: [HealthPermission] {
        statuses.compactMap { $0.value == .denied ? $0.key : nil }
    }

    public func status(for permission: HealthPermission) -> AuthorizationStatus {
        statuses[permission] ?? .notDetermined
    }
}
