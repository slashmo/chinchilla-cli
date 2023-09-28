// swift-tools-version:5.8
import PackageDescription

let swiftSettings: [SwiftSetting] = [.enableExperimentalFeature("StrictConcurrency")]

let package = Package(
    name: "chinchilla-cli",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "chinchilla", targets: ["CTL"]),
    ],
    targets: [
        .executableTarget(name: "CTL", swiftSettings: swiftSettings),
        .testTarget(name: "Unit", swiftSettings: swiftSettings),
    ]
)
