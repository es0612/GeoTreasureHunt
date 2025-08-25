// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GeoSonarUI",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "GeoSonarUI",
            targets: ["GeoSonarUI"]
        ),
    ],
    dependencies: [
        .package(path: "../GeoSonarCore"),
    ],
    targets: [
        .target(
            name: "GeoSonarUI",
            dependencies: ["GeoSonarCore"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "GeoSonarUITests",
            dependencies: ["GeoSonarUI"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)