// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GeoSonarTesting",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "GeoSonarTesting",
            targets: ["GeoSonarTesting"]
        ),
    ],
    dependencies: [
        .package(path: "../GeoSonarCore"),
    ],
    targets: [
        .target(
            name: "GeoSonarTesting",
            dependencies: ["GeoSonarCore"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "GeoSonarTestingTests",
            dependencies: ["GeoSonarTesting"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)