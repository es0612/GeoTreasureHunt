// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GeoSonarCore",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "GeoSonarCore",
            targets: ["GeoSonarCore"]
        ),
    ],
    dependencies: [
        // Add external dependencies here if needed
    ],
    targets: [
        .target(
            name: "GeoSonarCore",
            dependencies: [],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "GeoSonarCoreTests",
            dependencies: ["GeoSonarCore"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)