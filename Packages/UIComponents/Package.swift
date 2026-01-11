// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "UIComponents",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "UIComponents",
            targets: ["UIComponents"]
        ),
    ],
    dependencies: [
        .package(path: "../SharedCore")
    ],
    targets: [
        .target(
            name: "UIComponents",
            dependencies: ["SharedCore"],
            path: "Sources"
        ),
    ]
)