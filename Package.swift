// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "JWWTestExtensions",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
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
