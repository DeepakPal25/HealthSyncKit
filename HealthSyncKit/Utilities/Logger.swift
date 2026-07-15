import Foundation
import os.log

public enum LogLevel: Int, Comparable, Sendable {
    case debug = 0
    case info = 1
    case warning = 2
    case error = 3
    case none = 4

    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

public final class HealthLogger: @unchecked Sendable {

    public static let shared = HealthLogger()

    private let osLog = OSLog(subsystem: "com.healthsynckit", category: "HealthSyncKit")
    private(set) var minimumLevel: LogLevel = .info

    private init() {}

    public func configure(minimumLevel: LogLevel) {
        self.minimumLevel = minimumLevel
    }

    func debug(_ message: String, file: String = #file, line: Int = #line) {
        log(message, level: .debug, file: file, line: line)
    }

    func info(_ message: String, file: String = #file, line: Int = #line) {
        log(message, level: .info, file: file, line: line)
    }

    func warning(_ message: String, file: String = #file, line: Int = #line) {
        log(message, level: .warning, file: file, line: line)
    }

    func error(_ message: String, file: String = #file, line: Int = #line) {
        log(message, level: .error, file: file, line: line)
    }

    private func log(_ message: String, level: LogLevel, file: String, line: Int) {
        guard level >= minimumLevel else { return }
        let fileName = (file as NSString).lastPathComponent
        let formatted = "[\(fileName):\(line)] \(message)"
        switch level {
        case .debug:   os_log(.debug,   log: osLog, "%{public}@", formatted)
        case .info:    os_log(.info,    log: osLog, "%{public}@", formatted)
        case .warning: os_log(.default, log: osLog, "%{public}@", formatted)
        case .error:   os_log(.error,   log: osLog, "%{public}@", formatted)
        case .none:    break
        }
    }
}
