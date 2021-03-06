// swift-tools-version:5.4

import PackageDescription

let package = Package(
    name: "JWWTestExtensions",
    platforms: [
        .iOS(.v14),
        .macOS(.v10_15),
        .tvOS(.v14),
        .watchOS(.v7)
    ],
    products: [
        .library(name: "JWWTestExtensions", targets: ["JWWTestExtensions"])
    ],
    targets: [
        .target(name: "JWWTestExtensions")
    ]
)
