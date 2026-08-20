// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HealthSyncKit",
    platforms: [
        .iOS(.v16),
        .watchOS(.v9),
        .macOS(.v13),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "HealthSyncKit",
            targets: ["HealthSyncKit"]
        )
    ],
    targets: [
        .target(
            name: "HealthSyncKit",
            path: "HealthSyncKit/HealthSyncKit",
            exclude: ["HealthSyncKit.docc"]
        ),
        .testTarget(
            name: "HealthSyncKitTests",
            dependencies: ["HealthSyncKit"],
            path: "HealthSyncKit/HealthSyncKitTests"
        )
    ]
)
