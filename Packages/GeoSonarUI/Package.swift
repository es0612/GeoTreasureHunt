// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "GeoSonarUI",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "GeoSonarUI",
            targets: ["GeoSonarUI"]
        ),
    ],
    dependencies: [
        .package(path: "../GeoSonarCore"),
        .package(path: "../GeoSonarTesting"),
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
            dependencies: [
                "GeoSonarUI",
                .product(name: "GeoSonarTesting", package: "GeoSonarTesting")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)