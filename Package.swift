// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AnotherSwiftCommonLib",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "AnotherSwiftCommonLib",
            targets: ["AnotherSwiftCommonLib"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "AnotherSwiftCommonLib",
            dependencies: []
        ),
        .testTarget(
            name: "AnotherSwiftCommonLibTests",
            dependencies: ["AnotherSwiftCommonLib"]
        ),
    ]
)
