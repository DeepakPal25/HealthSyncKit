import Foundation

/// Configuration for HealthSyncKit behaviour and permissions.
public struct HealthConfiguration: Sendable {
    public let readPermissions: Set<HealthPermission>
    public let writePermissions: Set<HealthPermission>
    public let logLevel: LogLevel

    public init(
        readPermissions: Set<HealthPermission> = Set(HealthPermission.allCases),
        writePermissions: Set<HealthPermission> = [],
        logLevel: LogLevel = .info
    ) {
        self.readPermissions = readPermissions
        self.writePermissions = writePermissions
        self.logLevel = logLevel
    }

    public static let `default` = HealthConfiguration()

    public static func readOnly(_ permissions: Set<HealthPermission>) -> HealthConfiguration {
        HealthConfiguration(readPermissions: permissions, writePermissions: [], logLevel: .info)
    }

    public static func readWrite(
        read: Set<HealthPermission>,
        write: Set<HealthPermission>
    ) -> HealthConfiguration {
        HealthConfiguration(readPermissions: read, writePermissions: write, logLevel: .info)
    }
}
