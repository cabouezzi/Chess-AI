// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Chess-AI-Package",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        // 👇 This defines the name of the executable output
        .executable(
            name: "chaniels-chess-engine",
            targets: ["Chess-AI-Package"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.90.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "Chess-AI-Package",
            dependencies: [
                .product(name: "Vapor", package: "vapor")
            ]
        ),
    ]
)
