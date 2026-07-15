import HealthKit

/// Internal adapter wrapping HKHealthStore. Not part of the public API.
final class HealthStore {

    let store: HKHealthStore

    init() {
        self.store = HKHealthStore()
    }

    func requestAuthorization(toShare: Set<HKSampleType>, read: Set<HKObjectType>) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            store.requestAuthorization(toShare: toShare, read: read) { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }

    func authorizationStatus(for type: HKObjectType) -> HKAuthorizationStatus {
        store.authorizationStatus(for: type)
    }

    func execute(_ query: HKQuery) {
        store.execute(query)
    }

    func stop(_ query: HKQuery) {
        store.stop(query)
    }
}
