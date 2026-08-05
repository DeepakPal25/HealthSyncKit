import Foundation

/// Aggregated summary of a sleep session.
public struct SleepSummary: Sendable {
    public let date: Date
    public let totalSleep: Double       // hours
    public let deepSleep: Double        // hours
    public let remSleep: Double         // hours
    public let coreSleep: Double        // hours
    public let awake: Double            // hours
    public let sleepEfficiency: Double  // 0–100
    public let sleepScore: Int          // 0–100

    public init(
        date: Date = Date(),
        totalSleep: Double,
        deepSleep: Double,
        remSleep: Double,
        coreSleep: Double = 0,
        awake: Double,
        sleepEfficiency: Double,
        sleepScore: Int
    ) {
        self.date = date
        self.totalSleep = totalSleep
        self.deepSleep = deepSleep
        self.remSleep = remSleep
        self.coreSleep = coreSleep
        self.awake = awake
        self.sleepEfficiency = sleepEfficiency
        self.sleepScore = sleepScore
    }
}

/// Calculates sleep metrics and scores from raw SleepSample arrays.
public enum SleepAnalytics {

    // MARK: - Summary

    public static func summary(from samples: [SleepSample], date: Date = Date()) -> SleepSummary {
        let sleeping = samples.filter { $0.stage != .awake && $0.stage != .unknown }
        let awake    = samples.filter { $0.stage == .awake }
        let deep     = sleeping.filter { $0.stage == .deep }
        let rem      = sleeping.filter { $0.stage == .rem }
        let core     = sleeping.filter { $0.stage == .core || $0.stage == .asleep }

        let totalSleep  = sleeping.reduce(0) { $0 + $1.durationInHours }
        let deepHours   = deep.reduce(0)    { $0 + $1.durationInHours }
        let remHours    = rem.reduce(0)     { $0 + $1.durationInHours }
        let coreHours   = core.reduce(0)    { $0 + $1.durationInHours }
        let awakeHours  = awake.reduce(0)   { $0 + $1.durationInHours }

        let totalBed = totalSleep + awakeHours
        let efficiency = totalBed > 0 ? (totalSleep / totalBed) * 100 : 0
        let score = calculateScore(
            totalSleep: totalSleep,
            deepSleep: deepHours,
            remSleep: remHours,
            efficiency: efficiency
        )
        return SleepSummary(
            date: date,
            totalSleep: totalSleep,
            deepSleep: deepHours,
            remSleep: remHours,
            coreSleep: coreHours,
            awake: awakeHours,
            sleepEfficiency: efficiency,
            sleepScore: score
        )
    }

    // MARK: - Sleep Score (0–100)

    /// Scores sleep quality based on duration, stage distribution, and efficiency.
    ///
    /// - Duration  (0–40): Optimal 7–9 hours
    /// - Deep sleep (0–25): Optimal ~20 % of total sleep
    /// - REM sleep  (0–25): Optimal ~20 % of total sleep
    /// - Efficiency (0–10): Optimal 85 %+
    public static func calculateScore(
        totalSleep: Double,
        deepSleep: Double,
        remSleep: Double,
        efficiency: Double
    ) -> Int {
        let durationScore: Double
        switch totalSleep {
        case 7...9:      durationScore = 40
        case 6..<7:      durationScore = 30
        case 9..<10:     durationScore = 30
        case 5..<6:      durationScore = 20
        case 10...:      durationScore = 20
        default:         durationScore = max(0, totalSleep / 5 * 20)
        }

        let deepRatio  = totalSleep > 0 ? (deepSleep / totalSleep) * 100 : 0
        let remRatio   = totalSleep > 0 ? (remSleep  / totalSleep) * 100 : 0
        let deepScore  = min(25.0, deepRatio * 1.25)
        let remScore   = min(25.0, remRatio  * 1.25)
        let effScore   = min(10.0, efficiency / 10)

        return min(100, max(0, Int((durationScore + deepScore + remScore + effScore).rounded())))
    }

    // MARK: - Averages & Consistency

    public static func weeklyAverageSleep(from samples: [SleepSample]) -> Double {
        guard !samples.isEmpty else { return 0 }
        let grouped = Dictionary(grouping: samples) {
            Calendar.current.startOfDay(for: $0.startDate)
        }
        let dailyTotals = grouped.values.map { daySamples in
            daySamples.filter { $0.stage != .awake }.reduce(0) { $0 + $1.durationInHours }
        }
        return dailyTotals.reduce(0, +) / Double(dailyTotals.count)
    }

    /// Returns a consistency score (0–100) based on bedtime variance.
    /// Lower variance = higher score.
    public static func sleepConsistencyScore(from samples: [SleepSample]) -> Double {
        let grouped = Dictionary(grouping: samples) {
            Calendar.current.startOfDay(for: $0.startDate)
        }
        let bedtimes: [Double] = grouped.values.compactMap { daySamples in
            guard let earliest = daySamples.min(by: { $0.startDate < $1.startDate }) else { return nil }
            let comps = Calendar.current.dateComponents([.hour, .minute], from: earliest.startDate)
            return Double((comps.hour ?? 0) * 60 + (comps.minute ?? 0))
        }
        guard bedtimes.count >= 2 else { return 0 }
        let mean     = bedtimes.reduce(0, +) / Double(bedtimes.count)
        let variance = bedtimes.map { pow($0 - mean, 2) }.reduce(0, +) / Double(bedtimes.count)
        let stdDev   = sqrt(variance)
        return max(0, 100 - (stdDev / 90 * 100))
    }
}
