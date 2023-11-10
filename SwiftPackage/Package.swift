// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ubuntu-build",
    products: [
        .executable(name: "UCI", targets: ["ubuntu-build"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "ubuntu-build",
            path: "Sources"),
    ]
)
