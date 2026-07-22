import Foundation

/// A single recorded health measurement. No HealthKit types are exposed.
public struct QuantitySample: Identifiable, Hashable, Sendable {
    public let id: UUID
    public let metricType: HealthMetricType
    public let value: Double
    public let unit: String
    public let startDate: Date
    public let endDate: Date
    public let sourceName: String?
    public let device: String?

    public init(
        id: UUID = UUID(),
        metricType: HealthMetricType,
        value: Double,
        unit: String,
        startDate: Date,
        endDate: Date,
        sourceName: String? = nil,
        device: String? = nil
    ) {
        self.id = id
        self.metricType = metricType
        self.value = value
        self.unit = unit
        self.startDate = startDate
        self.endDate = endDate
        self.sourceName = sourceName
        self.device = device
    }

    public var duration: TimeInterval {
        endDate.timeIntervalSince(startDate)
    }
}
