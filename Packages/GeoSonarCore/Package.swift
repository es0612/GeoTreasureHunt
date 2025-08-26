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
        .package(path: "../GeoSonarTesting"),
    ],
    targets: [
        .target(
            name: "GeoSonarCore",
            dependencies: [],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "GeoSonarCoreTests",
            dependencies: [
                "GeoSonarCore",
                "GeoSonarTesting"
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)