import Foundation

/// Identifies a specific type of health metric for querying.
/// No HealthKit types are exposed.
public enum HealthMetricType: String, CaseIterable, Hashable, Sendable {

    // Activity
    case stepCount
    case distanceWalkingRunning
    case distanceCycling
    case distanceSwimming
    case activeEnergyBurned
    case basalEnergyBurned
    case flightsClimbed
    case appleExerciseTime
    case appleStandTime

    // Body
    case height
    case bodyMass
    case bodyMassIndex
    case bodyFatPercentage
    case leanBodyMass
    case waistCircumference

    // Vitals
    case heartRate
    case restingHeartRate
    case walkingHeartRateAverage
    case heartRateVariabilitySDNN
    case bloodPressureSystolic
    case bloodPressureDiastolic
    case respiratoryRate
    case oxygenSaturation
    case bodyTemperature
    case bloodGlucose

    // Nutrition
    case dietaryEnergyConsumed
    case dietaryCarbohydrates
    case dietaryFiber
    case dietarySugar
    case dietaryFatTotal
    case dietaryProtein
    case dietaryWater
    case dietaryCaffeine
    case dietarySodium

    public var displayName: String {
        switch self {
        case .stepCount:                return "Steps"
        case .distanceWalkingRunning:   return "Walking + Running Distance"
        case .distanceCycling:          return "Cycling Distance"
        case .distanceSwimming:         return "Swimming Distance"
        case .activeEnergyBurned:       return "Active Calories"
        case .basalEnergyBurned:        return "Resting Calories"
        case .flightsClimbed:           return "Flights Climbed"
        case .appleExerciseTime:        return "Exercise Minutes"
        case .appleStandTime:           return "Stand Minutes"
        case .height:                   return "Height"
        case .bodyMass:                 return "Weight"
        case .bodyMassIndex:            return "BMI"
        case .bodyFatPercentage:        return "Body Fat"
        case .leanBodyMass:             return "Lean Body Mass"
        case .waistCircumference:       return "Waist Circumference"
        case .heartRate:                return "Heart Rate"
        case .restingHeartRate:         return "Resting Heart Rate"
        case .walkingHeartRateAverage:  return "Walking Heart Rate"
        case .heartRateVariabilitySDNN: return "Heart Rate Variability"
        case .bloodPressureSystolic:    return "Systolic Blood Pressure"
        case .bloodPressureDiastolic:   return "Diastolic Blood Pressure"
        case .respiratoryRate:          return "Respiratory Rate"
        case .oxygenSaturation:         return "Blood Oxygen"
        case .bodyTemperature:          return "Body Temperature"
        case .bloodGlucose:             return "Blood Glucose"
        case .dietaryEnergyConsumed:    return "Dietary Energy"
        case .dietaryCarbohydrates:     return "Carbohydrates"
        case .dietaryFiber:             return "Fiber"
        case .dietarySugar:             return "Sugar"
        case .dietaryFatTotal:          return "Total Fat"
        case .dietaryProtein:           return "Protein"
        case .dietaryWater:             return "Water"
        case .dietaryCaffeine:          return "Caffeine"
        case .dietarySodium:            return "Sodium"
        }
    }
}
