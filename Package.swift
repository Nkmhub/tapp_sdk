// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Tapp",
    platforms: [
        .iOS(.v13) // Define platform version if necessary
    ],
    products: [
        .library(
            name: "Tapp",
            targets: ["Tapp"]
        ),
    ],
    dependencies: [
        // Adjust SDK Git repository and version
        .package(url: "https://github.com/adjust/ios_sdk.git", exact: "5.0.1")
    ],
    targets: [
        .target(
            name: "Tapp",
            dependencies: [
                .product(name: "AdjustSdk", package: "ios_sdk")  // Adjust SDK dependency
            ]
        ),
        .testTarget(
            name: "TappTests",
            dependencies: ["Tapp"]
        ),
    ]
)
