// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "MatteScreen",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "MatteScreen", targets: ["MatteScreen"])
    ],
    targets: [
        .executableTarget(
            name: "MatteScreen",
            resources: [
                .process("Resources")
            ],
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("CoreGraphics"),
                .linkedFramework("Metal"),
                .linkedFramework("MetalKit")
            ]
        ),
        .testTarget(
            name: "MatteScreenTests",
            dependencies: ["MatteScreen"]
        )
    ]
)
