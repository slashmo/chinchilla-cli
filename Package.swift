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
        .testTarget(name: "Unit", swiftSettings: swiftSettings),

        .target(
            name: "ChinchillaCTLCore",
            dependencies: [],
            swiftSettings: swiftSettings,
            plugins: [
                .plugin(name: "GitStatusPlugin"),
            ]
        ),

        .plugin(
            name: "GitStatusPlugin",
            capability: .buildTool,
            dependencies: ["GitStatus"]
        ),
        .executableTarget(name: "GitStatus"),
    ]
)
