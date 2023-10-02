// swift-tools-version:5.9
import PackageDescription

let swiftSettings: [SwiftSetting] = [.enableExperimentalFeature("StrictConcurrency")]

let package = Package(
    name: "chinchilla-cli",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "chinchilla", targets: ["ChinchillaCTL"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.6"),

        .package(url: "https://github.com/slashmo/chinchilla.git", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "ChinchillaCTL",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log"),

                .target(name: "ChinchillaConfig"),
                .target(name: "ChinchillaCTLCore"),
            ],
            swiftSettings: swiftSettings
        ),

        .target(
            name: "ChinchillaConfig",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
                .product(name: "Yams", package: "Yams"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "ChinchillaConfigTests",
            dependencies: [
                .target(name: "ChinchillaConfig"),
            ],
            swiftSettings: swiftSettings
        ),

        .target(
            name: "ChinchillaCTLCore",
            dependencies: [
                .target(name: "ChinchillaConfig"),
                .product(name: "Chinchilla", package: "chinchilla"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "Unit",
            dependencies: [
                .target(name: "ChinchillaCTLCore"),
            ],
            swiftSettings: swiftSettings
        ),
    ]
)
