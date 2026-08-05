import Foundation

/// Statistical computations on QuantitySample collections.
public enum HealthStatistics {

    public static func mean(of samples: [QuantitySample]) -> Double {
        guard !samples.isEmpty else { return 0 }
        return samples.reduce(0) { $0 + $1.value } / Double(samples.count)
    }

    public static func median(of samples: [QuantitySample]) -> Double {
        guard !samples.isEmpty else { return 0 }
        let sorted = samples.map { $0.value }.sorted()
        let mid = sorted.count / 2
        return sorted.count % 2 == 0
            ? (sorted[mid - 1] + sorted[mid]) / 2
            : sorted[mid]
    }

    public static func standardDeviation(of samples: [QuantitySample]) -> Double {
        guard samples.count > 1 else { return 0 }
        let avg = mean(of: samples)
        let variance = samples.reduce(0) { $0 + pow($1.value - avg, 2) } / Double(samples.count)
        return sqrt(variance)
    }

    public static func minimum(of samples: [QuantitySample]) -> Double? {
        samples.map { $0.value }.min()
    }

    public static func maximum(of samples: [QuantitySample]) -> Double? {
        samples.map { $0.value }.max()
    }

    public static func sum(of samples: [QuantitySample]) -> Double {
        samples.reduce(0) { $0 + $1.value }
    }

    /// Calculates a simple moving average over `window` samples.
    public static func movingAverage(of samples: [QuantitySample], window: Int) -> [Double] {
        guard window > 0, samples.count >= window else { return [] }
        return (0...(samples.count - window)).map { i in
            let slice = samples[i..<(i + window)]
            return slice.reduce(0) { $0 + $1.value } / Double(window)
        }
    }

    /// Returns the percentage change from `oldValue` to `newValue`.
    public static func percentChange(from oldValue: Double, to newValue: Double) -> Double {
        guard oldValue != 0 else { return newValue > 0 ? 100 : -100 }
        return ((newValue - oldValue) / abs(oldValue)) * 100
    }

    /// Linear regression slope — positive means upward trend, negative means downward.
    public static func trend(of samples: [QuantitySample]) -> Double {
        guard samples.count >= 2 else { return 0 }
        let n = Double(samples.count)
        let xs = (0..<samples.count).map { Double($0) }
        let ys = samples.map { $0.value }
        let sumX  = xs.reduce(0, +)
        let sumY  = ys.reduce(0, +)
        let sumXY = zip(xs, ys).reduce(0) { $0 + $1.0 * $1.1 }
        let sumX2 = xs.reduce(0) { $0 + $1 * $1 }
        let denom = n * sumX2 - sumX * sumX
        guard denom != 0 else { return 0 }
        return (n * sumXY - sumX * sumY) / denom
    }

    // MARK: - Grouping helpers

    public static func groupByDay(_ samples: [QuantitySample]) -> [Date: [QuantitySample]] {
        Dictionary(grouping: samples) {
            Calendar.current.startOfDay(for: $0.startDate)
        }
    }

    public static func groupByWeek(_ samples: [QuantitySample]) -> [Date: [QuantitySample]] {
        Dictionary(grouping: samples) { sample in
            let comps = Calendar.current.dateComponents(
                [.yearForWeekOfYear, .weekOfYear], from: sample.startDate
            )
            return Calendar.current.date(from: comps) ?? sample.startDate
        }
    }

    public static func groupByMonth(_ samples: [QuantitySample]) -> [Date: [QuantitySample]] {
        Dictionary(grouping: samples) { sample in
            let comps = Calendar.current.dateComponents([.year, .month], from: sample.startDate)
            return Calendar.current.date(from: comps) ?? sample.startDate
        }
    }
}
