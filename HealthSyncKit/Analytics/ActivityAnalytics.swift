import Foundation

/// Aggregated summary of a single day's activity.
public struct ActivitySummary: Sendable {
    public let date: Date
    public let steps: Double
    public let activeCalories: Double   // kcal
    public let distance: Double         // metres
    public let exerciseMinutes: Double
    public let standMinutes: Double

    public init(
        date: Date = Date(),
        steps: Double = 0,
        activeCalories: Double = 0,
        distance: Double = 0,
        exerciseMinutes: Double = 0,
        standMinutes: Double = 0
    ) {
        self.date = date
        self.steps = steps
        self.activeCalories = activeCalories
        self.distance = distance
        self.exerciseMinutes = exerciseMinutes
        self.standMinutes = standMinutes
    }

    public var activityScore: Int {
        ActivityAnalytics.calculateScore(summary: self)
    }
}

/// Calculates activity metrics from QuantitySample arrays.
public enum ActivityAnalytics {

    // MARK: - Daily Summary

    public static func dailySummary(from samples: [QuantitySample], on date: Date) -> ActivitySummary {
        let calendar = Calendar.current
        let day = samples.filter { calendar.isDate($0.startDate, inSameDayAs: date) }

        func total(_ metric: HealthMetricType) -> Double {
            day.filter { $0.metricType == metric }.reduce(0) { $0 + $1.value }
        }
        return ActivitySummary(
            date: date,
            steps: total(.stepCount),
            activeCalories: total(.activeEnergyBurned),
            distance: total(.distanceWalkingRunning),
            exerciseMinutes: total(.appleExerciseTime),
            standMinutes: total(.appleStandTime)
        )
    }

    // MARK: - Aggregates

    public static func weeklyStepAverage(from samples: [QuantitySample]) -> Double {
        let steps = samples.filter { $0.metricType == .stepCount }
        guard !steps.isEmpty else { return 0 }
        let grouped = Dictionary(grouping: steps) {
            Calendar.current.startOfDay(for: $0.startDate)
        }
        let dailyTotals = grouped.values.map { $0.reduce(0) { $0 + $1.value } }
        return dailyTotals.reduce(0, +) / Double(dailyTotals.count)
    }

    public static func goalProgress(current: Double, goal: Double) -> Double {
        guard goal > 0 else { return 0 }
        return min(1.0, current / goal)
    }

    // MARK: - Activity Score (0–100)

    /// Scores daily activity based on steps, calories, exercise and distance.
    ///
    /// - Steps           (0–40): Goal 10 000
    /// - Active calories (0–30): Goal 500 kcal
    /// - Exercise mins   (0–20): Goal 30 min
    /// - Distance        (0–10): Goal 5 km
    public static func calculateScore(summary: ActivitySummary) -> Int {
        let stepsScore    = min(40.0, summary.steps / 10_000 * 40)
        let calorieScore  = min(30.0, summary.activeCalories / 500 * 30)
        let exerciseScore = min(20.0, summary.exerciseMinutes / 30 * 20)
        let distanceScore = min(10.0, summary.distance / 5_000 * 10)
        let total = stepsScore + calorieScore + exerciseScore + distanceScore
        return min(100, max(0, Int(total.rounded())))
    }

    // MARK: - Streak

    /// Returns the current consecutive-day streak where the daily total meets `dailyGoal`.
    public static func streak(
        from samples: [QuantitySample],
        metric: HealthMetricType,
        dailyGoal: Double
    ) -> Int {
        let filtered = samples.filter { $0.metricType == metric }
        let grouped = Dictionary(grouping: filtered) {
            Calendar.current.startOfDay(for: $0.startDate)
        }
        let sortedDates = grouped.keys.sorted(by: >)
        var streak = 0
        var current = Calendar.current.startOfDay(for: Date())

        for date in sortedDates {
            guard Calendar.current.isDate(date, inSameDayAs: current) else { break }
            let dayTotal = grouped[date]?.reduce(0) { $0 + $1.value } ?? 0
            guard dayTotal >= dailyGoal else { break }
            streak += 1
            current = Calendar.current.date(byAdding: .day, value: -1, to: current) ?? current
        }
        return streak
    }
}
