import HealthKit

/// # HealthSyncClient
///
/// Primary entry point for HealthSyncKit — an open-source Swift SDK for Apple HealthKit.
///
/// ## Quick Start
/// ```swift
/// let health = HealthSyncClient()
///
/// // 1. Request permissions
/// try await health.requestAuthorization(for: [.steps, .sleep, .heartRate])
///
/// // 2. Read data
/// let steps = try await health.steps(from: yesterday, to: today)
/// let sleep = try await health.sleepSummary(from: yesterday, to: today)
/// print("Sleep score: \(sleep.sleepScore)")
/// ```
public final class HealthSyncClient: @unchecked Sendable {

    private let healthStore: HealthStore
    private let configuration: HealthConfiguration

    // MARK: - Init

    public init(configuration: HealthConfiguration = .default) {
        self.healthStore = HealthStore()
        self.configuration = configuration
        HealthLogger.shared.configure(minimumLevel: configuration.logLevel)
    }

    // MARK: - Availability

    public var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    // MARK: - Authorization

    @discardableResult
    public func requestAuthorization(
        for permissions: [HealthPermission]
    ) async throws -> AuthorizationResult {
        guard isHealthDataAvailable else {
            throw HealthError.healthDataNotAvailable
        }
        let manager = AuthorizationManager(store: healthStore)
        return try await manager.request(permissions: permissions)
    }

    public func authorizationStatus(for permission: HealthPermission) -> AuthorizationStatus {
        AuthorizationManager(store: healthStore).status(for: permission)
    }

    // MARK: - Activity

    public func steps(from start: Date, to end: Date) async throws -> [QuantitySample] {
        try await quantity(.stepCount, from: start, to: end)
    }

    public func activeEnergy(from start: Date, to end: Date) async throws -> [QuantitySample] {
        try await quantity(.activeEnergyBurned, from: start, to: end)
    }

    public func distance(from start: Date, to end: Date) async throws -> [QuantitySample] {
        try await quantity(.distanceWalkingRunning, from: start, to: end)
    }

    public func flightsClimbed(from start: Date, to end: Date) async throws -> [QuantitySample] {
        try await quantity(.flightsClimbed, from: start, to: end)
    }

    public func workouts(from start: Date, to end: Date) async throws -> [Workout] {
        let range = try DateRange(start: start, end: end)
        return try await WorkoutQuery(store: healthStore).execute(in: range)
    }

    // MARK: - Vitals

    public func heartRate(from start: Date, to end: Date) async throws -> [QuantitySample] {
        try await quantity(.heartRate, from: start, to: end)
    }

    public func restingHeartRate(from start: Date, to end: Date) async throws -> [QuantitySample] {
        try await quantity(.restingHeartRate, from: start, to: end)
    }

    public func heartRateVariability(from start: Date, to end: Date) async throws -> [QuantitySample] {
        try await quantity(.heartRateVariabilitySDNN, from: start, to: end)
    }

    public func oxygenSaturation(from start: Date, to end: Date) async throws -> [QuantitySample] {
        try await quantity(.oxygenSaturation, from: start, to: end)
    }

    public func respiratoryRate(from start: Date, to end: Date) async throws -> [QuantitySample] {
        try await quantity(.respiratoryRate, from: start, to: end)
    }

    public func bloodPressure(
        from start: Date, to end: Date
    ) async throws -> (systolic: [QuantitySample], diastolic: [QuantitySample]) {
        async let systolic  = quantity(.bloodPressureSystolic,  from: start, to: end)
        async let diastolic = quantity(.bloodPressureDiastolic, from: start, to: end)
        return try await (systolic, diastolic)
    }

    // MARK: - Body

    public func weight(from start: Date, to end: Date) async throws -> [QuantitySample] {
        try await quantity(.bodyMass, from: start, to: end)
    }

    public func bodyFatPercentage(from start: Date, to end: Date) async throws -> [QuantitySample] {
        try await quantity(.bodyFatPercentage, from: start, to: end)
    }

    // MARK: - Sleep

    public func sleep(from start: Date, to end: Date) async throws -> [SleepSample] {
        let range = try DateRange(start: start, end: end)
        return try await SleepQuery(store: healthStore).execute(in: range)
    }

    public func sleepSummary(from start: Date, to end: Date) async throws -> SleepSummary {
        let samples = try await sleep(from: start, to: end)
        return SleepAnalytics.summary(from: samples, date: start)
    }

    // MARK: - Statistics

    public func statistics(
        for metric: HealthMetricType,
        from start: Date,
        to end: Date,
        option: StatisticsOption = .sum
    ) async throws -> StatisticsResult {
        let range = try DateRange(start: start, end: end)
        return try await StatisticsQuery(store: healthStore).execute(
            metric: metric, in: range, option: option
        )
    }

    // MARK: - Generic Query

    public func quantity(
        _ metric: HealthMetricType,
        from start: Date,
        to end: Date,
        limit: Int = 0
    ) async throws -> [QuantitySample] {
        let range = try DateRange(start: start, end: end)
        return try await QuantityQuery(store: healthStore).execute(
            metric: metric, in: range, limit: limit
        )
    }
}
