// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "tapp_sdk",
    platforms: [
        .iOS(.v13) // Define platform version if necessary
    ],
    products: [
        .library(
            name: "tapp_sdk",
            targets: ["tapp_sdk"]
        ),
    ],
    dependencies: [
        // Adjust SDK Git repository and version
        .package(url: "https://github.com/adjust/ios_sdk.git", from: "5.0.0")
    ],
    targets: [
        .target(
            name: "tapp_sdk",
            dependencies: [
                .product(name: "AdjustSdk", package: "ios_sdk")  // Adjust SDK dependency
            ]
        ),
        .testTarget(
            name: "tapp_sdkTests",
            dependencies: ["tapp_sdk"]
        ),
    ]
)
