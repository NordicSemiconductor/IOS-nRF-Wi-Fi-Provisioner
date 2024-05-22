// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NordicWiFiProvisioner",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v13)
      ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "NordicWiFiProvisioner-BLE",
            targets: ["NordicWiFiProvisioner-BLE"]),
        .library(
            name: "NordicWiFiProvisioner-SoftAP",
            targets: ["NordicWiFiProvisioner-SoftAP"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.6.0"),
        .package(url: "https://github.com/NordicSemiconductor/IOS-CoreBluetooth-Mock.git", from: "0.18.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "NordicWiFiProvisioner-SoftAP",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
            ]),
        .target(
            name: "NordicWiFiProvisioner-BLE",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                .product(name: "CoreBluetoothMock", package: "IOS-CoreBluetooth-Mock")
            ]),
        .testTarget(
            name: "NordicWiFiProvisionerTests",
            dependencies: ["NordicWiFiProvisioner-BLE"],
            resources: [.process("Mock/MockAP.json")]
        )
    ]
)
