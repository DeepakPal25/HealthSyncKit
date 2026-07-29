import HealthKit

/// Internal mapper between domain types and HealthKit types.
/// Never exposed in the public API.
enum HealthKitMapper {

    // MARK: - Quantity Type Identifier

    static func quantityTypeIdentifier(for metric: HealthMetricType) -> HKQuantityTypeIdentifier? {
        switch metric {
        case .stepCount:                return .stepCount
        case .distanceWalkingRunning:   return .distanceWalkingRunning
        case .distanceCycling:          return .distanceCycling
        case .distanceSwimming:         return .distanceSwimming
        case .activeEnergyBurned:       return .activeEnergyBurned
        case .basalEnergyBurned:        return .basalEnergyBurned
        case .flightsClimbed:           return .flightsClimbed
        case .appleExerciseTime:        return .appleExerciseTime
        case .appleStandTime:           return .appleStandTime
        case .height:                   return .height
        case .bodyMass:                 return .bodyMass
        case .bodyMassIndex:            return .bodyMassIndex
        case .bodyFatPercentage:        return .bodyFatPercentage
        case .leanBodyMass:             return .leanBodyMass
        case .waistCircumference:       return .waistCircumference
        case .heartRate:                return .heartRate
        case .restingHeartRate:         return .restingHeartRate
        case .walkingHeartRateAverage:  return .walkingHeartRateAverage
        case .heartRateVariabilitySDNN: return .heartRateVariabilitySDNN
        case .bloodPressureSystolic:    return .bloodPressureSystolic
        case .bloodPressureDiastolic:   return .bloodPressureDiastolic
        case .respiratoryRate:          return .respiratoryRate
        case .oxygenSaturation:         return .oxygenSaturation
        case .bodyTemperature:          return .bodyTemperature
        case .bloodGlucose:             return .bloodGlucose
        case .dietaryEnergyConsumed:    return .dietaryEnergyConsumed
        case .dietaryCarbohydrates:     return .dietaryCarbohydrates
        case .dietaryFiber:             return .dietaryFiber
        case .dietarySugar:             return .dietarySugar
        case .dietaryFatTotal:          return .dietaryFatTotal
        case .dietaryProtein:           return .dietaryProtein
        case .dietaryWater:             return .dietaryWater
        case .dietaryCaffeine:          return .dietaryCaffeine
        case .dietarySodium:            return .dietarySodium
        }
    }

    // MARK: - HKUnit

    static func hkUnit(for metric: HealthMetricType) -> HKUnit {
        switch metric {
        case .stepCount, .flightsClimbed:
            return .count()
        case .distanceWalkingRunning, .distanceCycling, .distanceSwimming:
            return .meter()
        case .activeEnergyBurned, .basalEnergyBurned, .dietaryEnergyConsumed:
            return .kilocalorie()
        case .appleExerciseTime, .appleStandTime:
            return .minute()
        case .height, .waistCircumference:
            return HKUnit.meterUnit(with: .centi)
        case .bodyMass, .leanBodyMass:
            return HKUnit.gramUnit(with: .kilo)
        case .bodyMassIndex:
            return .count()
        case .bodyFatPercentage, .oxygenSaturation:
            return .percent()
        case .heartRate, .restingHeartRate, .walkingHeartRateAverage, .respiratoryRate:
            return HKUnit.count().unitDivided(by: .minute())
        case .heartRateVariabilitySDNN:
            return HKUnit.secondUnit(with: .milli)
        case .bloodPressureSystolic, .bloodPressureDiastolic:
            return .millimeterOfMercury()
        case .bodyTemperature:
            return .degreeCelsius()
        case .bloodGlucose:
            return HKUnit(from: "mg/dL")
        case .dietaryCarbohydrates, .dietaryFiber, .dietarySugar,
             .dietaryFatTotal, .dietaryProtein, .dietarySodium:
            return .gram()
        case .dietaryWater:
            return HKUnit.literUnit(with: .milli)
        case .dietaryCaffeine:
            return HKUnit.gramUnit(with: .milli)
        }
    }

    // MARK: - Display Unit String

    static func unitString(for metric: HealthMetricType) -> String {
        switch metric {
        case .stepCount, .flightsClimbed:                               return "steps"
        case .distanceWalkingRunning, .distanceCycling, .distanceSwimming: return "m"
        case .activeEnergyBurned, .basalEnergyBurned, .dietaryEnergyConsumed: return "kcal"
        case .appleExerciseTime, .appleStandTime:                       return "min"
        case .height, .waistCircumference:                              return "cm"
        case .bodyMass, .leanBodyMass:                                  return "kg"
        case .bodyMassIndex:                                            return "kg/m²"
        case .bodyFatPercentage, .oxygenSaturation:                     return "%"
        case .heartRate, .restingHeartRate, .walkingHeartRateAverage, .respiratoryRate: return "bpm"
        case .heartRateVariabilitySDNN:                                 return "ms"
        case .bloodPressureSystolic, .bloodPressureDiastolic:           return "mmHg"
        case .bodyTemperature:                                          return "°C"
        case .bloodGlucose:                                             return "mg/dL"
        case .dietaryCarbohydrates, .dietaryFiber, .dietarySugar,
             .dietaryFatTotal, .dietaryProtein, .dietarySodium:         return "g"
        case .dietaryWater:                                             return "mL"
        case .dietaryCaffeine:                                          return "mg"
        }
    }

    // MARK: - Workout Activity Type

    static func workoutActivityType(from hkType: HKWorkoutActivityType) -> WorkoutActivityType {
        switch hkType {
        case .running:                          return .running
        case .cycling:                          return .cycling
        case .swimming:                         return .swimming
        case .walking:                          return .walking
        case .hiking:                           return .hiking
        case .yoga:                             return .yoga
        case .functionalStrengthTraining,
             .traditionalStrengthTraining:      return .strengthTraining
        case .highIntensityIntervalTraining:    return .highIntensityIntervalTraining
        case .crossTraining:                    return .crossTraining
        case .dance, .socialDance, .cardioDance: return .dance
        case .elliptical:                       return .elliptical
        case .rowing:                           return .rowing
        case .stairClimbing, .stairs, .stepTraining: return .stairClimbing
        case .tennis, .tableTennis:             return .tennis
        case .soccer:                           return .soccer
        case .basketball:                       return .basketball
        case .baseball, .softball:              return .baseball
        case .golf:                             return .golf
        case .pilates:                          return .pilates
        case .barre:                            return .barre
        case .kickboxing:                       return .kickboxing
        case .boxing:                           return .boxing
        case .martialArts:                      return .martialArts
        case .mindAndBody, .taiChi:             return .mindAndBody
        default:                                return .other
        }
    }

    // MARK: - Sleep Stage

    static func sleepStage(from value: Int) -> SleepStage {
        guard let hkValue = HKCategoryValueSleepAnalysis(rawValue: value) else {
            return .unknown
        }
        switch hkValue {
        case .inBed:              return .asleep
        case .asleepUnspecified:  return .asleep
        case .awake:              return .awake
        case .asleepCore:         return .core
        case .asleepDeep:         return .deep
        case .asleepREM:          return .rem
        @unknown default:         return .unknown
        }
    }
}
