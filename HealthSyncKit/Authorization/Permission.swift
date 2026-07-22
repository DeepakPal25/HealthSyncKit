import HealthKit

/// A HealthKit data type that requires user permission.
/// No HKObjectType is exposed in the public interface.
public enum HealthPermission: String, CaseIterable, Hashable, Sendable {

    // Activity
    case steps
    case distanceWalkingRunning
    case distanceCycling
    case activeEnergyBurned
    case basalEnergyBurned
    case flightsClimbed
    case exerciseTime
    case standTime

    // Body
    case height
    case weight
    case bodyMassIndex
    case bodyFatPercentage
    case leanBodyMass
    case waistCircumference

    // Vitals
    case heartRate
    case restingHeartRate
    case heartRateVariability
    case bloodPressureSystolic
    case bloodPressureDiastolic
    case respiratoryRate
    case oxygenSaturation
    case bodyTemperature
    case bloodGlucose

    // Sleep
    case sleep

    // Workouts
    case workouts

    // Nutrition
    case dietaryEnergy
    case dietaryCarbohydrates
    case dietaryProtein
    case dietaryFat
    case dietaryWater

    // MARK: - Internal HKKit Mapping

    var hkObjectType: HKObjectType? {
        switch self {
        case .steps:                return HKObjectType.quantityType(forIdentifier: .stepCount)
        case .distanceWalkingRunning: return HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)
        case .distanceCycling:      return HKObjectType.quantityType(forIdentifier: .distanceCycling)
        case .activeEnergyBurned:   return HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)
        case .basalEnergyBurned:    return HKObjectType.quantityType(forIdentifier: .basalEnergyBurned)
        case .flightsClimbed:       return HKObjectType.quantityType(forIdentifier: .flightsClimbed)
        case .exerciseTime:         return HKObjectType.quantityType(forIdentifier: .appleExerciseTime)
        case .standTime:            return HKObjectType.quantityType(forIdentifier: .appleStandTime)
        case .height:               return HKObjectType.quantityType(forIdentifier: .height)
        case .weight:               return HKObjectType.quantityType(forIdentifier: .bodyMass)
        case .bodyMassIndex:        return HKObjectType.quantityType(forIdentifier: .bodyMassIndex)
        case .bodyFatPercentage:    return HKObjectType.quantityType(forIdentifier: .bodyFatPercentage)
        case .leanBodyMass:         return HKObjectType.quantityType(forIdentifier: .leanBodyMass)
        case .waistCircumference:   return HKObjectType.quantityType(forIdentifier: .waistCircumference)
        case .heartRate:            return HKObjectType.quantityType(forIdentifier: .heartRate)
        case .restingHeartRate:     return HKObjectType.quantityType(forIdentifier: .restingHeartRate)
        case .heartRateVariability: return HKObjectType.quantityType(forIdentifier: .heartRateVariabilitySDNN)
        case .bloodPressureSystolic:  return HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)
        case .bloodPressureDiastolic: return HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)
        case .respiratoryRate:      return HKObjectType.quantityType(forIdentifier: .respiratoryRate)
        case .oxygenSaturation:     return HKObjectType.quantityType(forIdentifier: .oxygenSaturation)
        case .bodyTemperature:      return HKObjectType.quantityType(forIdentifier: .bodyTemperature)
        case .bloodGlucose:         return HKObjectType.quantityType(forIdentifier: .bloodGlucose)
        case .sleep:                return HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        case .workouts:             return HKObjectType.workoutType()
        case .dietaryEnergy:        return HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed)
        case .dietaryCarbohydrates: return HKObjectType.quantityType(forIdentifier: .dietaryCarbohydrates)
        case .dietaryProtein:       return HKObjectType.quantityType(forIdentifier: .dietaryProtein)
        case .dietaryFat:           return HKObjectType.quantityType(forIdentifier: .dietaryFatTotal)
        case .dietaryWater:         return HKObjectType.quantityType(forIdentifier: .dietaryWater)
        }
    }

    var hkSampleType: HKSampleType? { hkObjectType as? HKSampleType }
}
