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
    dependencies: [
        .package(url: "https://github.com/justin/jww-core-data.git", from: "0.5.1"),
        .package(url: "https://github.com/justin/jww-standard-lib.git", from: "1.3.0")
    ],
    targets: [
        .target(name: "JWWTestExtensions", dependencies: [
            .product(name: "JWW Core Data", package: "jww-core-data"),
            .product(name: "JWWCore", package: "jww-standard-lib")
        ]),
        .testTarget(name: "JWWTestExtensionsTests", dependencies: [
            .targetItem(name: "JWWTestExtensions", condition: nil)
        ])
    ]
)
