// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Provisioner",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v11)
      ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Provisioner",
            targets: ["Provisioner"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.6.0"),
        .package(url: "https://github.com/NordicSemiconductor/IOS-CoreBluetooth-Mock.git", from: "0.14.0")
    ],
    targets: [
        .target(
            name: "Provisioner",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "CoreBluetoothMock", package: "IOS-CoreBluetooth-Mock")
            ]),
        .testTarget(
            name: "ProvisionerTests",
            dependencies: ["Provisioner"],
            resources: [.process("Mock/MockAP.json")]
        )
    ]
)
