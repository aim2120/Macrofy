// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "Demo",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "DemoPropertyWrapper",
            targets: ["DemoPropertyWrapper"]
        ),
        .library(
            name: "DemoMacro",
            targets: ["DemoMacro"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "601.0.0-latest"),
        .package(path: ".."),
    ],
    targets: [
        .target(name: "DemoPropertyWrapper",
                dependencies: []),

        .macro(name: "DemoMacroInternal",
               dependencies: [
                   .product(name: "Macrofy", package: "Macrofy"),
                   .product(name: "SwiftSyntax", package: "swift-syntax"),
                   .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                   .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
               ]),

        .target(name: "DemoMacro",
                dependencies: [
                    "DemoMacroInternal",
                ]),

        .testTarget(name: "DemoTests",
                    dependencies: [
                        "DemoMacro",
                        "DemoMacroInternal",
                        "DemoPropertyWrapper",
                        .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                    ]),
    ],
    swiftLanguageModes: [.v6]
)
