// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SharedCore",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "SharedCore",
            targets: ["SharedCore"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SharedCore",
            path: "Sources"
        ),
        .testTarget(
            name: "SharedCoreTests",
            dependencies: ["SharedCore"],
            path: "Tests"
        ),
    ]
)