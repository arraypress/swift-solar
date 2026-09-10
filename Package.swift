// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "swift-solar",
    platforms: [
        .macOS(.v14), .iOS(.v16), .tvOS(.v16), .watchOS(.v9), .visionOS(.v1),
    ],
    products: [
        .library(name: "Solar", targets: ["Solar"]),
    ],
    targets: [
        .target(name: "Solar"),
        .testTarget(name: "SolarTests", dependencies: ["Solar"]),
    ]
)
