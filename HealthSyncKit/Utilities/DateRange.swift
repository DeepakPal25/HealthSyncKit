import Foundation

/// A bounded time interval for health data queries.
public struct DateRange: Sendable, Equatable {
    public let start: Date
    public let end: Date

    public init(start: Date, end: Date) throws {
        guard start <= end else { throw HealthError.dateRangeInvalid }
        self.start = start
        self.end = end
    }

    public var duration: TimeInterval {
        end.timeIntervalSince(start)
    }

    // MARK: - Factories

    public static func today() throws -> DateRange {
        let now = Date()
        let start = Calendar.current.startOfDay(for: now)
        return try DateRange(start: start, end: now)
    }

    public static func yesterday() throws -> DateRange {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let start = calendar.date(byAdding: .day, value: -1, to: today) ?? today
        return try DateRange(start: start, end: today)
    }

    public static func lastDays(_ count: Int) throws -> DateRange {
        let end = Date()
        let start = Calendar.current.date(byAdding: .day, value: -count, to: end) ?? end
        return try DateRange(start: start, end: end)
    }

    public static func lastWeek() throws -> DateRange  { try lastDays(7) }
    public static func lastMonth() throws -> DateRange { try lastDays(30) }
    public static func lastYear() throws -> DateRange  { try lastDays(365) }

    public static func thisWeek() throws -> DateRange {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let now = Date()
        let start = calendar.date(
            from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        ) ?? now
        return try DateRange(start: start, end: now)
    }

    public static func thisMonth() throws -> DateRange {
        let now = Date()
        let start = Calendar.current.date(
            from: Calendar.current.dateComponents([.year, .month], from: now)
        ) ?? now
        return try DateRange(start: start, end: now)
    }

    // MARK: - Helpers

    public func contains(_ date: Date) -> Bool {
        date >= start && date <= end
    }

    /// Splits the range into sub-ranges by the given calendar component.
    public func split(by component: Calendar.Component, calendar: Calendar = .current) -> [DateRange] {
        var ranges: [DateRange] = []
        var current = start
        while current < end {
            guard let next = calendar.date(byAdding: component, value: 1, to: current) else { break }
            let rangeEnd = min(next, end)
            if let range = try? DateRange(start: current, end: rangeEnd) {
                ranges.append(range)
            }
            current = next
        }
        return ranges
    }
}
