// swift-tools-version:5.8
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
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(name: "Unit", swiftSettings: swiftSettings),
    ]
)
