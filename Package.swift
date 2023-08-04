// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JSONRPC-DataChannel-Actor",
    platforms: [
      .macOS(.v13)
    ],

    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "JSONRPC-DataChannel-Actor",
            targets: ["JSONRPC-DataChannel-Actor"]),
    ],

    dependencies: [
      .package(url: "https://github.com/ChimeHQ/JSONRPC", from: "0.8.0"),
      .package(
        url: "https://github.com/apple/swift-collections.git",
        .upToNextMinor(from: "1.0.0") // or `.upToNextMajor
      )
    ],

    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "JSONRPC-DataChannel-Actor",
            dependencies: [
              "JSONRPC",
              .product(name: "Collections", package: "swift-collections")
            ]),
        .testTarget(
            name: "JSONRPC-DataChannel-ActorTests",
            dependencies: ["JSONRPC-DataChannel-Actor"]),
    ]
)
