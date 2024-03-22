// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "IntegratingJS",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "IntegratingJS", targets: ["IntegratingJS"]),
    ],
    dependencies: [
        .package(url: "https://github.com/SleekDiamond41/Operators.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "IntegratingJS",
            dependencies: [
                .product(name: "Operators", package: "Operators"),
            ]
        ),
        .testTarget(
            name: "IntegratingJSTests",
            dependencies: [
                "IntegratingJS",
            ]
        ),
    ]
)
