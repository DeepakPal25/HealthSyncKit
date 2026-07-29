import HealthKit

struct QuantityQuery {

    private let store: HealthStore

    init(store: HealthStore) {
        self.store = store
    }

    func execute(
        metric: HealthMetricType,
        in dateRange: DateRange,
        limit: Int = 0,
        ascending: Bool = false
    ) async throws -> [QuantitySample] {

        guard let typeIdentifier = HealthKitMapper.quantityTypeIdentifier(for: metric),
              let quantityType = HKObjectType.quantityType(forIdentifier: typeIdentifier) else {
            throw HealthError.unsupportedMetric(metric.rawValue)
        }

        let predicate = HKQuery.predicateForSamples(
            withStart: dateRange.start,
            end: dateRange.end,
            options: .strictStartDate
        )
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: ascending)
        let queryLimit = limit == 0 ? HKObjectQueryNoLimit : limit

        let hkUnit = HealthKitMapper.hkUnit(for: metric)
        let unitString = HealthKitMapper.unitString(for: metric)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: quantityType,
                predicate: predicate,
                limit: queryLimit,
                sortDescriptors: [sort]
            ) { _, samples, error in
                if let error {
                    continuation.resume(throwing: HealthError.queryFailed(error.localizedDescription))
                    return
                }
                let results: [QuantitySample] = (samples ?? []).compactMap { sample in
                    guard let qs = sample as? HKQuantitySample else { return nil }
                    return QuantitySample(
                        id: qs.uuid,
                        metricType: metric,
                        value: qs.quantity.doubleValue(for: hkUnit),
                        unit: unitString,
                        startDate: qs.startDate,
                        endDate: qs.endDate,
                        sourceName: qs.sourceRevision.source.name,
                        device: qs.device?.name
                    )
                }
                continuation.resume(returning: results)
            }
            store.execute(query)
        }
    }
}
