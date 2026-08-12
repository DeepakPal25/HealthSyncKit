import Testing
import Foundation
@testable import HealthSyncKit

// MARK: - DateRange Tests

@Suite("DateRange")
struct DateRangeTests {

    @Test func validRangeCreation() throws {
        let start = Date(timeIntervalSinceNow: -3600)
        let end   = Date()
        let range = try DateRange(start: start, end: end)
        #expect(range.start == start)
        #expect(range.end == end)
        #expect(range.duration == end.timeIntervalSince(start))
    }

    @Test func invalidRangeThrows() {
        let future = Date(timeIntervalSinceNow: 3600)
        let past   = Date(timeIntervalSinceNow: -3600)
        #expect(throws: HealthError.dateRangeInvalid) {
            try DateRange(start: future, end: past)
        }
    }

    @Test func todayFactory() throws {
        let range = try DateRange.today()
        #expect(range.start <= range.end)
        #expect(range.duration >= 0)
    }

    @Test func lastDaysFactory() throws {
        let range = try DateRange.lastDays(7)
        let sevenDaysInSeconds: TimeInterval = 7 * 24 * 3600
        #expect(range.duration <= sevenDaysInSeconds + 60)
    }

    @Test func containsDate() throws {
        let start = Date(timeIntervalSinceNow: -3600)
        let end   = Date()
        let range = try DateRange(start: start, end: end)
        #expect(range.contains(Date(timeIntervalSinceNow: -1800)))
        #expect(!range.contains(Date(timeIntervalSinceNow: 60)))
    }
}

// MARK: - SleepSample Tests

@Suite("SleepSample")
struct SleepSampleTests {

    @Test func durationCalculation() {
        let start  = Date(timeIntervalSinceNow: -28800)
        let end    = Date()
        let sample = SleepSample(stage: .deep, startDate: start, endDate: end)
        #expect(abs(sample.durationInHours - 8.0) < 0.01)
        #expect(abs(sample.durationInMinutes - 480.0) < 1.0)
    }

    @Test func restorativeStages() {
        #expect(SleepStage.deep.isRestorative)
        #expect(SleepStage.rem.isRestorative)
        #expect(!SleepStage.awake.isRestorative)
        #expect(!SleepStage.core.isRestorative)
    }
}

// MARK: - SleepAnalytics Tests

@Suite("SleepAnalytics")
struct SleepAnalyticsTests {

    @Test func summaryCalculation() {
        let base = Date(timeIntervalSinceNow: -28800)
        let samples: [SleepSample] = [
            SleepSample(stage: .core,  startDate: base,
                        endDate: base.addingTimeInterval(3600 * 4)),
            SleepSample(stage: .deep,  startDate: base.addingTimeInterval(3600 * 4),
                        endDate: base.addingTimeInterval(3600 * 5.5)),
            SleepSample(stage: .rem,   startDate: base.addingTimeInterval(3600 * 5.5),
                        endDate: base.addingTimeInterval(3600 * 7.5)),
            SleepSample(stage: .awake, startDate: base.addingTimeInterval(3600 * 7.5),
                        endDate: base.addingTimeInterval(3600 * 8)),
        ]
        let summary = SleepAnalytics.summary(from: samples)
        #expect(abs(summary.totalSleep - 7.5) < 0.01)
        #expect(abs(summary.deepSleep  - 1.5) < 0.01)
        #expect(abs(summary.remSleep   - 2.0) < 0.01)
        #expect(abs(summary.awake      - 0.5) < 0.01)
        #expect(summary.sleepScore > 0)
        #expect(summary.sleepScore <= 100)
    }

    @Test func sleepScorePerfectSleep() {
        let score = SleepAnalytics.calculateScore(
            totalSleep: 8.0, deepSleep: 1.6, remSleep: 1.6, efficiency: 92.0
        )
        #expect(score >= 80)
    }

    @Test func sleepScorePoorSleep() {
        let score = SleepAnalytics.calculateScore(
            totalSleep: 4.0, deepSleep: 0.1, remSleep: 0.1, efficiency: 60.0
        )
        #expect(score < 50)
    }

    @Test func emptySamplesReturnsZero() {
        let summary = SleepAnalytics.summary(from: [])
        #expect(summary.totalSleep == 0)
        #expect(summary.sleepScore == 0)
    }
}

// MARK: - QuantitySample Tests

@Suite("QuantitySample")
struct QuantitySampleTests {

    @Test func sampleCreation() {
        let now    = Date()
        let sample = QuantitySample(
            metricType: .stepCount, value: 1234, unit: "steps",
            startDate: now, endDate: now
        )
        #expect(sample.value == 1234)
        #expect(sample.metricType == .stepCount)
        #expect(sample.unit == "steps")
    }

    @Test func uniqueIDs() {
        let now = Date()
        let a = QuantitySample(metricType: .heartRate, value: 60, unit: "bpm", startDate: now, endDate: now)
        let b = QuantitySample(metricType: .heartRate, value: 60, unit: "bpm", startDate: now, endDate: now)
        #expect(a.id != b.id)
    }
}

// MARK: - ActivityAnalytics Tests

@Suite("ActivityAnalytics")
struct ActivityAnalyticsTests {

    @Test func activityScoreMax() {
        let summary = ActivitySummary(
            steps: 15_000, activeCalories: 700,
            distance: 12_000, exerciseMinutes: 60, standMinutes: 10
        )
        #expect(summary.activityScore == 100)
    }

    @Test func activityScoreZero() {
        let summary = ActivitySummary()
        #expect(summary.activityScore == 0)
    }

    @Test func goalProgress() {
        #expect(ActivityAnalytics.goalProgress(current: 5000, goal: 10_000) == 0.5)
        #expect(ActivityAnalytics.goalProgress(current: 15_000, goal: 10_000) == 1.0)
        #expect(ActivityAnalytics.goalProgress(current: 0, goal: 0) == 0)
    }
}

// MARK: - HealthStatistics Tests

@Suite("HealthStatistics")
struct HealthStatisticsTests {

    private func samples(_ values: [Double]) -> [QuantitySample] {
        values.map { v in
            QuantitySample(metricType: .stepCount, value: v, unit: "steps",
                           startDate: Date(), endDate: Date())
        }
    }

    @Test func mean()   { #expect(HealthStatistics.mean(of: samples([2, 4, 6, 8, 10])) == 6.0) }
    @Test func median() { #expect(HealthStatistics.median(of: samples([1, 3, 5, 7, 9])) == 5.0) }

    @Test func standardDeviation() {
        let sd = HealthStatistics.standardDeviation(of: samples([2, 4, 4, 4, 5, 5, 7, 9]))
        #expect(abs(sd - 2.0) < 0.01)
    }

    @Test func percentChange() {
        #expect(HealthStatistics.percentChange(from: 100, to: 150) == 50.0)
        #expect(HealthStatistics.percentChange(from: 100, to: 50)  == -50.0)
    }

    @Test func movingAverage() {
        let avg = HealthStatistics.movingAverage(of: samples([1, 2, 3, 4, 5]), window: 3)
        #expect(avg.count == 3)
        #expect(avg[0] == 2.0)
        #expect(avg[2] == 4.0)
    }

    @Test func trendPositive() {
        #expect(HealthStatistics.trend(of: samples([1, 2, 3, 4, 5])) > 0)
    }
}

// MARK: - HealthError Tests

@Suite("HealthError")
struct HealthErrorTests {

    @Test func descriptions() {
        #expect(HealthError.healthDataNotAvailable.errorDescription != nil)
        #expect(HealthError.authorizationDenied.errorDescription != nil)
        #expect(HealthError.queryFailed("timeout").errorDescription?.contains("timeout") == true)
    }

    @Test func recoverySuggestions() {
        #expect(HealthError.healthDataNotAvailable.recoverySuggestion != nil)
        #expect(HealthError.authorizationDenied.recoverySuggestion != nil)
    }
}

// MARK: - Workout Tests

@Suite("Workout")
struct WorkoutTests {

    @Test func durationHelpers() {
        let workout = Workout(
            activityType: .running,
            startDate: Date(timeIntervalSinceNow: -3600),
            endDate: Date(),
            duration: 3600
        )
        #expect(workout.durationInMinutes == 60)
        #expect(workout.durationInHours == 1)
    }
}

// MARK: - HealthSyncClient Tests

@Suite("HealthSyncClient")
struct HealthSyncClientTests {

    @Test func initSucceeds() {
        let client = HealthSyncClient()
        _ = client.isHealthDataAvailable
    }

    @Test func customConfigurationRespected() {
        let config = HealthConfiguration(readPermissions: [.steps, .heartRate], logLevel: .debug)
        let client = HealthSyncClient(configuration: config)
        _ = client.isHealthDataAvailable
    }
}
