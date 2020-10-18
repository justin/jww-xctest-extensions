// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "JWWTestExtensions",
    platforms: [
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(name: "JWWTestExtensions", targets: ["JWWTestExtensions"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "JWWTestExtensions", dependencies: []),
    ]
)
