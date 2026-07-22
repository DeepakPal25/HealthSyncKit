import Foundation

/// Stage of a sleep interval.
public enum SleepStage: String, CaseIterable, Sendable {
    case awake
    case asleep
    case core
    case deep
    case rem
    case unknown

    public var displayName: String {
        switch self {
        case .awake:   return "Awake"
        case .asleep:  return "Asleep"
        case .core:    return "Core Sleep"
        case .deep:    return "Deep Sleep"
        case .rem:     return "REM Sleep"
        case .unknown: return "Unknown"
        }
    }

    public var isRestorative: Bool {
        self == .deep || self == .rem
    }
}

/// A sleep interval with stage information. No HealthKit types are exposed.
public struct SleepSample: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let stage: SleepStage
    public let startDate: Date
    public let endDate: Date
    public let sourceName: String?

    public init(
        id: UUID = UUID(),
        stage: SleepStage,
        startDate: Date,
        endDate: Date,
        sourceName: String? = nil
    ) {
        self.id = id
        self.stage = stage
        self.startDate = startDate
        self.endDate = endDate
        self.sourceName = sourceName
    }

    public var duration: TimeInterval     { endDate.timeIntervalSince(startDate) }
    public var durationInHours: Double    { duration / 3600 }
    public var durationInMinutes: Double  { duration / 60 }
}
