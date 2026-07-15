import Foundation

public enum HealthError: Error, LocalizedError, Equatable, Sendable {
    case healthDataNotAvailable
    case authorizationDenied
    case authorizationNotDetermined
    case authorizationRestricted
    case queryFailed(String)
    case invalidData(String)
    case unsupportedMetric(String)
    case dateRangeInvalid

    public var errorDescription: String? {
        switch self {
        case .healthDataNotAvailable:
            return "HealthKit is not available on this device."
        case .authorizationDenied:
            return "Authorization to access health data was denied."
        case .authorizationNotDetermined:
            return "Authorization has not been requested. Call requestAuthorization() first."
        case .authorizationRestricted:
            return "Authorization is restricted by a device policy."
        case .queryFailed(let reason):
            return "Health query failed: \(reason)"
        case .invalidData(let detail):
            return "Invalid health data: \(detail)"
        case .unsupportedMetric(let name):
            return "Health metric '\(name)' is not supported on this device or OS version."
        case .dateRangeInvalid:
            return "Start date must be before or equal to end date."
        }
    }

    public var recoverySuggestion: String? {
        switch self {
        case .healthDataNotAvailable:
            return "HealthKit requires a physical iPhone or Apple Watch."
        case .authorizationDenied:
            return "Go to Settings → Privacy & Security → Health to grant access."
        case .authorizationNotDetermined:
            return "Call requestAuthorization(for:) before reading health data."
        default:
            return nil
        }
    }
}
