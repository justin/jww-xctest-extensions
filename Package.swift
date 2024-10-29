// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "JWWTestExtensions",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .tvOS(.v14),
        .visionOS(.v1),
        .watchOS(.v7)
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
