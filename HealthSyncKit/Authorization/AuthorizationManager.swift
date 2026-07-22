import HealthKit

struct AuthorizationManager {

    private let store: HealthStore

    init(store: HealthStore) {
        self.store = store
    }

    func request(permissions: [HealthPermission]) async throws -> AuthorizationResult {
        let objectTypes = Set(permissions.compactMap { $0.hkObjectType })
        let sampleTypes = Set(permissions.compactMap { $0.hkSampleType })

        try await store.requestAuthorization(toShare: sampleTypes, read: objectTypes)

        var statuses: [HealthPermission: AuthorizationStatus] = [:]
        for permission in permissions {
            statuses[permission] = status(for: permission)
        }
        return AuthorizationResult(statuses: statuses)
    }

    func status(for permission: HealthPermission) -> AuthorizationStatus {
        guard let objectType = permission.hkObjectType else { return .notDetermined }
        return AuthorizationStatus(store.authorizationStatus(for: objectType))
    }
}
