import HealthKit

struct WorkoutQuery {

    private let store: HealthStore

    init(store: HealthStore) {
        self.store = store
    }

    func execute(in dateRange: DateRange, limit: Int = 0) async throws -> [Workout] {
        let workoutType = HKObjectType.workoutType()

        let predicate = HKQuery.predicateForSamples(
            withStart: dateRange.start,
            end: dateRange.end,
            options: .strictStartDate
        )
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let queryLimit = limit == 0 ? HKObjectQueryNoLimit : limit

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: workoutType,
                predicate: predicate,
                limit: queryLimit,
                sortDescriptors: [sort]
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: HealthError.queryFailed(error.localizedDescription))
                    return
                }
                let energyUnit = HKUnit.kilocalorie()
                let distanceUnit = HKUnit.meter()
                let results: [Workout] = (samples ?? []).compactMap { sample in
                    guard let w = sample as? HKWorkout else { return nil }
                    return Workout(
                        id: w.uuid,
                        activityType: HealthKitMapper.workoutActivityType(from: w.workoutActivityType),
                        startDate: w.startDate,
                        endDate: w.endDate,
                        duration: w.duration,
                        totalEnergyBurned: w.totalEnergyBurned?.doubleValue(for: energyUnit),
                        totalDistance: w.totalDistance?.doubleValue(for: distanceUnit),
                        sourceName: w.sourceRevision.source.name
                    )
                }
                continuation.resume(returning: results)
            }
            store.execute(query)
        }
    }
}
