# HealthSyncKit

Open-source Swift SDK for Apple HealthKit — clean async/await API, domain models with no HealthKit types exposed, and a built-in analytics layer.

---

## Features

| Category | Data Types |
|---|---|
| **Activity** | Steps, distance, calories, flights climbed, exercise & stand minutes, workouts |
| **Vitals** | Heart rate, resting HR, HRV, blood pressure, oxygen saturation, respiratory rate |
| **Body** | Weight, height, BMI, body fat %, lean mass, waist circumference |
| **Sleep** | All stages (core, deep, REM, awake) with sleep score (0–100) |
| **Nutrition** | Dietary energy, carbs, protein, fat, water, caffeine, sodium |
| **Analytics** | Sleep summary, activity summary, statistics (mean, trend, moving average) |

---

## Requirements

- iOS 16+
- Swift 6+
- Xcode 16+

---

## Installation

### Swift Package Manager

Add HealthSyncKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/DeepakPal25/HealthSyncKit.git", from: "1.0.0")
]
```

Then add it to your target:

```swift
.target(
    name: "YourApp",
    dependencies: ["HealthSyncKit"]
)
```

### Xcode

1. File → Add Package Dependencies
2. Enter: `https://github.com/DeepakPal25/HealthSyncKit.git`
3. Select version rule and click **Add Package**

---

## Quick Start

```swift
import HealthSyncKit

let health = HealthSyncClient()

// 1. Check availability
guard health.isHealthDataAvailable else { return }

// 2. Request permissions
try await health.requestAuthorization(for: [.steps, .sleep, .heartRate, .weight])

// 3. Read steps for the last week
let steps = try await health.steps(from: lastWeek, to: today)
print("Recorded \(steps.count) step entries")

// 4. Sleep summary with score
let sleep = try await health.sleepSummary(from: yesterday, to: today)
print("Sleep score: \(sleep.sleepScore)/100")
print("Total sleep: \(String(format: "%.1f", sleep.totalSleep))h")
print("Deep sleep:  \(String(format: "%.1f", sleep.deepSleep))h")
print("REM sleep:   \(String(format: "%.1f", sleep.remSleep))h")
```

---

## API Reference

### Authorization

```swift
let client = HealthSyncClient()

// Request specific permissions
let result = try await client.requestAuthorization(for: [.steps, .heartRate, .sleep])

// Check a single permission
let status = client.authorizationStatus(for: .heartRate)
if status.isAuthorized { ... }
```

### Activity

```swift
let steps       = try await client.steps(from: start, to: end)
let energy      = try await client.activeEnergy(from: start, to: end)
let distance    = try await client.distance(from: start, to: end)
let flights     = try await client.flightsClimbed(from: start, to: end)
let workouts    = try await client.workouts(from: start, to: end)
```

### Vitals

```swift
let heartRate   = try await client.heartRate(from: start, to: end)
let restingHR   = try await client.restingHeartRate(from: start, to: end)
let hrv         = try await client.heartRateVariability(from: start, to: end)
let spo2        = try await client.oxygenSaturation(from: start, to: end)
let respRate    = try await client.respiratoryRate(from: start, to: end)
let (sys, dia)  = try await client.bloodPressure(from: start, to: end)
```

### Body

```swift
let weight      = try await client.weight(from: start, to: end)
let bodyFat     = try await client.bodyFatPercentage(from: start, to: end)
```

### Sleep

```swift
// Raw sleep samples with stage information
let samples = try await client.sleep(from: start, to: end)

// Aggregated summary with analytics score
let summary = try await client.sleepSummary(from: start, to: end)
// summary.totalSleep    → hours asleep
// summary.deepSleep     → deep sleep hours
// summary.remSleep      → REM hours
// summary.sleepScore    → 0–100 score
// summary.sleepEfficiency → percentage
```

### Statistics

```swift
// Aggregated statistics for any metric
let totalSteps = try await client.statistics(
    for: .stepCount, from: start, to: end, option: .sum
)
let avgHeartRate = try await client.statistics(
    for: .heartRate, from: start, to: end, option: .average
)
```

### Generic Query

```swift
// Query any supported HealthMetricType
let samples = try await client.quantity(.bloodGlucose, from: start, to: end)
```

---

## Analytics

### Sleep Analytics

```swift
// Score a single night
let score = SleepAnalytics.calculateScore(
    totalSleep: 7.5,
    deepSleep: 1.5,
    remSleep: 2.0,
    efficiency: 91.0
)
// → 88

// Weekly average sleep
let avgSleep = SleepAnalytics.weeklyAverageSleep(from: samples)

// Bedtime consistency score (0–100)
let consistency = SleepAnalytics.sleepConsistencyScore(from: samples)
```

### Activity Analytics

```swift
// Daily summary from raw samples
let summary = ActivityAnalytics.dailySummary(from: samples, on: today)
print("Activity score: \(summary.activityScore)/100")

// Step streak
let streak = ActivityAnalytics.streak(from: samples, metric: .stepCount, dailyGoal: 10_000)
print("Current streak: \(streak) days")
```

### Health Statistics

```swift
let mean   = HealthStatistics.mean(of: heartRateSamples)
let stdDev = HealthStatistics.standardDeviation(of: heartRateSamples)
let trend  = HealthStatistics.trend(of: stepSamples)          // slope
let ma     = HealthStatistics.movingAverage(of: samples, window: 7)
let change = HealthStatistics.percentChange(from: 8000, to: 10200)
```

---

## Architecture

```
HealthSyncClient  (Public API)
       ↓
Domain Models     (QuantitySample, SleepSample, Workout — no HK types)
       ↓
Use Cases         (Queries, Analytics, Statistics)
       ↓
HealthKit Adapter (HealthStore, HealthKitMapper — internal only)
       ↓
Apple HealthKit
```

### Key design principles

- **No HealthKit types in the public API** — all models are pure Swift `Sendable` structs
- **Async/await throughout** — no callbacks, no Combine
- **Testable** — pure domain models and analytics can be tested without a device
- **Cross-platform ready** — clean model layer makes Flutter/React Native bridges straightforward

---

## Supported Permissions

```swift
// Activity
.steps, .distanceWalkingRunning, .distanceCycling
.activeEnergyBurned, .basalEnergyBurned, .flightsClimbed
.exerciseTime, .standTime, .workouts

// Body
.height, .weight, .bodyMassIndex, .bodyFatPercentage, .leanBodyMass

// Vitals
.heartRate, .restingHeartRate, .heartRateVariability
.bloodPressureSystolic, .bloodPressureDiastolic
.respiratoryRate, .oxygenSaturation, .bodyTemperature, .bloodGlucose

// Sleep
.sleep

// Nutrition
.dietaryEnergy, .dietaryCarbohydrates, .dietaryProtein, .dietaryFat, .dietaryWater
```

---

## Project Structure

```
HealthSyncKit/
├── Core/
│   ├── HealthStore.swift          # Internal HKHealthStore adapter
│   ├── HealthError.swift          # Typed errors with recovery suggestions
│   └── HealthConfiguration.swift  # Permission + log-level configuration
├── Authorization/
│   ├── Permission.swift           # HealthPermission enum (no HK types exposed)
│   ├── AuthorizationStatus.swift  # Status + AuthorizationResult
│   └── AuthorizationManager.swift # Async authorization handler
├── Models/
│   ├── HealthMetric.swift         # HealthMetricType enum (34 metrics)
│   ├── QuantitySample.swift       # Single health measurement
│   ├── SleepSample.swift          # Sleep interval with SleepStage
│   └── Workout.swift              # Workout session model
├── Queries/
│   ├── HealthKitMapper.swift      # Internal HK type bridge
│   ├── QuantityQuery.swift        # Async quantity sample query
│   ├── SleepQuery.swift           # Async sleep analysis query
│   ├── WorkoutQuery.swift         # Async workout query
│   └── StatisticsQuery.swift      # Async statistics query
├── Analytics/
│   ├── SleepAnalytics.swift       # Sleep score + summaries
│   ├── ActivityAnalytics.swift    # Activity score + streaks
│   └── HealthStatistics.swift     # Mean, median, trend, moving average
└── Utilities/
    ├── DateRange.swift            # Bounded time intervals with factories
    └── Logger.swift               # OSLog-backed HealthLogger
```

---

## License

MIT License — see [LICENSE](LICENSE) for details.

---

## Contributing

Contributions are welcome. Please open an issue first to discuss what you would like to change.

1. Fork the repo
2. Create your branch (`git checkout -b feature/new-metric`)
3. Commit your changes
4. Push to the branch
5. Open a Pull Request
