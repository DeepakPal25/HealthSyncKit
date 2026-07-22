import Foundation

/// Type of physical workout activity. No HealthKit types are exposed.
public enum WorkoutActivityType: String, CaseIterable, Sendable {
    case running, cycling, swimming, walking, hiking
    case yoga, strengthTraining, highIntensityIntervalTraining
    case crossTraining, dance, elliptical, rowing, stairClimbing
    case tennis, soccer, basketball, baseball, golf
    case pilates, barre, kickboxing, boxing, martialArts, mindAndBody
    case other

    public var displayName: String {
        switch self {
        case .running:                      return "Running"
        case .cycling:                      return "Cycling"
        case .swimming:                     return "Swimming"
        case .walking:                      return "Walking"
        case .hiking:                       return "Hiking"
        case .yoga:                         return "Yoga"
        case .strengthTraining:             return "Strength Training"
        case .highIntensityIntervalTraining: return "HIIT"
        case .crossTraining:                return "Cross Training"
        case .dance:                        return "Dance"
        case .elliptical:                   return "Elliptical"
        case .rowing:                       return "Rowing"
        case .stairClimbing:                return "Stair Climbing"
        case .tennis:                       return "Tennis"
        case .soccer:                       return "Soccer"
        case .basketball:                   return "Basketball"
        case .baseball:                     return "Baseball"
        case .golf:                         return "Golf"
        case .pilates:                      return "Pilates"
        case .barre:                        return "Barre"
        case .kickboxing:                   return "Kickboxing"
        case .boxing:                       return "Boxing"
        case .martialArts:                  return "Martial Arts"
        case .mindAndBody:                  return "Mind & Body"
        case .other:                        return "Other"
        }
    }
}

/// A recorded workout session. No HealthKit types are exposed.
public struct Workout: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let activityType: WorkoutActivityType
    public let startDate: Date
    public let endDate: Date
    public let duration: TimeInterval
    public let totalEnergyBurned: Double?   // kcal
    public let totalDistance: Double?        // metres
    public let sourceName: String?

    public init(
        id: UUID = UUID(),
        activityType: WorkoutActivityType,
        startDate: Date,
        endDate: Date,
        duration: TimeInterval,
        totalEnergyBurned: Double? = nil,
        totalDistance: Double? = nil,
        sourceName: String? = nil
    ) {
        self.id = id
        self.activityType = activityType
        self.startDate = startDate
        self.endDate = endDate
        self.duration = duration
        self.totalEnergyBurned = totalEnergyBurned
        self.totalDistance = totalDistance
        self.sourceName = sourceName
    }

    public var durationInMinutes: Double { duration / 60 }
    public var durationInHours: Double   { duration / 3600 }
}
