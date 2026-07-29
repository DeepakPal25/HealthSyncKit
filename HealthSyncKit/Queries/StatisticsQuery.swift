import HealthKit

/// Aggregation option for a statistics query.
public enum StatisticsOption: Sendable {
    case sum
    case average
    case minimum
    case maximum
    case mostRecent

    var hkOptions: HKStatisticsOptions {
        switch self {
        case .sum:        return .cumulativeSum
        case .average:    return .discreteAverage
        case .minimum:    return .discreteMin
        case .maximum:    return .discreteMax
        case .mostRecent: return .mostRecent
        }
    }
}

/// The result of a statistics query.
public struct StatisticsResult: Sendable {
    public let metricType: HealthMetricType
    public let value: Double?
    public let unit: String
    public let startDate: Date
    public let endDate: Date

    public var isAvailable: Bool { value != nil }
}

struct StatisticsQuery {

    private let store: HealthStore

    init(store: HealthStore) {
        self.store = store
    }

    func execute(
        metric: HealthMetricType,
        in dateRange: DateRange,
        option: StatisticsOption
    ) async throws -> StatisticsResult {

        guard let typeIdentifier = HealthKitMapper.quantityTypeIdentifier(for: metric),
              let quantityType = HKObjectType.quantityType(forIdentifier: typeIdentifier) else {
            throw HealthError.unsupportedMetric(metric.rawValue)
        }

        let predicate = HKQuery.predicateForSamples(
            withStart: dateRange.start,
            end: dateRange.end,
            options: .strictStartDate
        )
        let hkUnit = HealthKitMapper.hkUnit(for: metric)
        let unitString = HealthKitMapper.unitString(for: metric)

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: option.hkOptions
            ) { _, statistics, error in
                if let error {
                    continuation.resume(throwing: HealthError.queryFailed(error.localizedDescription))
                    return
                }
                let quantity: HKQuantity? = {
                    switch option {
                    case .sum:        return statistics?.sumQuantity()
                    case .average:    return statistics?.averageQuantity()
                    case .minimum:    return statistics?.minimumQuantity()
                    case .maximum:    return statistics?.maximumQuantity()
                    case .mostRecent: return statistics?.mostRecentQuantity()
                    }
                }()
                let result = StatisticsResult(
                    metricType: metric,
                    value: quantity?.doubleValue(for: hkUnit),
                    unit: unitString,
                    startDate: dateRange.start,
                    endDate: dateRange.end
                )
                continuation.resume(returning: result)
            }
            store.execute(query)
        }
    }
}
