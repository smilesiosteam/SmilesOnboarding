// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SmilesOnboarding",
    platforms: [
        .iOS(.v13)
    ], products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "SmilesOnboarding",
            targets: ["SmilesOnboarding"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/smilesiosteam/SmilesBaseMainRequest.git", .upToNextMinor(from: "1.0.0")),
        .package(url: "https://github.com/smilesiosteam/NetworkingLayer.git", .upToNextMinor(from: "1.0.0")),
        .package(url: "https://github.com/smilesiosteam/SmilesLoader.git", .upToNextMinor(from: "1.0.0")),
        .package(url: "https://github.com/smilesiosteam/SmilesLanguageManager.git", .upToNextMinor(from: "1.0.0")),
        .package(url: "https://github.com/smilesiosteam/LottieAnimationManager.git", .upToNextMinor(from: "1.0.0")),
//        .package(url: "https://github.com/michaeltyson/TPKeyboardAvoiding.git", branch: "master"),
        .package(url: "https://github.com/smilesiosteam/SmilesFontsManager.git", .upToNextMinor(from: "1.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "SmilesOnboarding",
            dependencies: [
                .product(name: "SmilesBaseMainRequestManager", package: "SmilesBaseMainRequest"),
                .product(name: "NetworkingLayer", package: "NetworkingLayer"),
                .product(name: "SmilesLoader", package: "SmilesLoader"),
                .product(name: "SmilesLanguageManager", package: "SmilesLanguageManager"),
                .product(name: "LottieAnimationManager", package: "LottieAnimationManager"),
//                .product(name: "TPKeyboardAvoiding", package: "TPKeyboardAvoiding"),
                .product(name: "SmilesFontsManager", package: "SmilesFontsManager")
            ], resources: [.process("Resources")]),
        .testTarget(
            name: "SmilesOnboardingTests",
            dependencies: ["SmilesOnboarding"]),
    ]
)
