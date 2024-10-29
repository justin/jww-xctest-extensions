// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "JWWTestExtensions",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .visionOS(.v1),
        .watchOS(.v8)
    ],
    products: [
        .library(name: "JWWTestExtensions", targets: ["JWWTestExtensions"])
    ],
    targets: [
        .target(name: "JWWTestExtensions"),
        .testTarget(name: "JWWTestExtensionsTests", dependencies: [
            .targetItem(name: "JWWTestExtensions", condition: nil)
        ])
    ]
)
