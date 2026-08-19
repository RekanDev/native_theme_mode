// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "native_theme_mode",
    platforms: [
        .iOS("12.0"),
    ],
    products: [
        // Plugin names with "_" must use "-" in the SwiftPM library name.
        .library(name: "native-theme-mode", targets: ["native_theme_mode"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "native_theme_mode",
            dependencies: [],
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ]
        ),
    ]
)
