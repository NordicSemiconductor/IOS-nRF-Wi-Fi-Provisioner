// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Provisioner2",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v11)
      ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Provisioner2",
            targets: ["Provisioner2"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.6.0"),
        .package(url: "https://github.com/NordicSemiconductor/IOS-CoreBluetooth-Mock.git", from: "0.14.0")
    ],
    targets: [
        .target(
            name: "Provisioner2",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "CoreBluetoothMock", package: "IOS-CoreBluetooth-Mock")
            ]),
        .testTarget(
            name: "Provisioner2Tests",
            dependencies: ["Provisioner2"]),
    ]
)
