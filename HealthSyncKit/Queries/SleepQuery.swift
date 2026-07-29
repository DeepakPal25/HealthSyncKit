import HealthKit

struct SleepQuery {

    private let store: HealthStore

    init(store: HealthStore) {
        self.store = store
    }

    func execute(in dateRange: DateRange) async throws -> [SleepSample] {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            throw HealthError.unsupportedMetric("sleepAnalysis")
        }

        let predicate = HKQuery.predicateForSamples(
            withStart: dateRange.start,
            end: dateRange.end,
            options: .strictStartDate
        )
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [sort]
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: HealthError.queryFailed(error.localizedDescription))
                    return
                }
                let results: [SleepSample] = (samples ?? []).compactMap { sample in
                    guard let cs = sample as? HKCategorySample else { return nil }
                    return SleepSample(
                        id: cs.uuid,
                        stage: HealthKitMapper.sleepStage(from: cs.value),
                        startDate: cs.startDate,
                        endDate: cs.endDate,
                        sourceName: cs.sourceRevision.source.name
                    )
                }
                continuation.resume(returning: results)
            }
            store.execute(query)
        }
    }
}
