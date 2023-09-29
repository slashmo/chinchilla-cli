// swift-tools-version:5.9
import PackageDescription

let swiftSettings: [SwiftSetting] = [.enableExperimentalFeature("StrictConcurrency")]

let package = Package(
    name: "chinchilla-cli",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "chinchilla", targets: ["CTL"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.6"),
        .package(url: "https://github.com/slashmo/chinchilla.git", branch: "main"),
    ],
    targets: [
        .executableTarget(
            name: "CTL",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .target(name: "ChinchillaCTLCore"),
            ],
            swiftSettings: swiftSettings
        ),

        .target(
            name: "ChinchillaCTLCore",
            dependencies: [
                .product(name: "Yams", package: "Yams"),
                .product(name: "Chinchilla", package: "chinchilla"),
            ],
            swiftSettings: swiftSettings,
            plugins: [
                .plugin(name: "GitStatusPlugin"),
            ]
        ),
        .testTarget(
            name: "Unit",
            dependencies: [
                .target(name: "ChinchillaCTLCore"),
            ],
            swiftSettings: swiftSettings
        ),

        .plugin(
            name: "GitStatusPlugin",
            capability: .buildTool,
            dependencies: ["GitStatus"]
        ),
        .executableTarget(name: "GitStatus"),
    ]
)
