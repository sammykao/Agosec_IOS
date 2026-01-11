// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OCR",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "OCR",
            targets: ["OCR"]
        ),
    ],
    dependencies: [
        .package(path: "../SharedCore")
    ],
    targets: [
        .target(
            name: "OCR",
            dependencies: ["SharedCore"],
            path: "Sources"
        ),
    ]
)