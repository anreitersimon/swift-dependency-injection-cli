// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-dependency-injection-cli",
    products: [
        .executable(
            name: "swift-dependency-injection",
            targets: ["swift-dependency-injection"]
        ),
        .library(
            name: "DependencyAnalyzer",
            targets: ["DependencyAnalyzer"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/anreitersimon/swift-package-utils",
            branch: "main"
        ),
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            branch: "0.50600.1"
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/pointfreeco/swift-custom-dump",
            from: "0.3.0"
        ),
    ],
    targets: [
        .executableTarget(
            name: "swift-dependency-injection",
            dependencies: [
                "DependencyInjectionKit",
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                ),
            ]
        ),
        .target(
            name: "SourceModel",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxParser", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "DependencyModel",
            dependencies: [
                "SourceModel"
            ]
        ),
        .target(
            name: "DependencyAnalyzer",
            dependencies: [
                "DependencyModel"
            ]
        ),
        .target(
            name: "CodeGeneration",
            dependencies: [
                "DependencyModel"
            ]
        ),
        .target(
            name: "DependencyInjectionKit",
            dependencies: [
                "DependencyAnalyzer",
                "DependencyModel",
                "CodeGeneration",
            ]
        ),
        .testTarget(
            name: "SourceModelTests",
            dependencies: [
                "SourceModel",
                .product(
                    name: "CustomDump",
                    package: "swift-custom-dump"
                ),
            ],
            exclude: [
                "Fixtures"
            ]
        ),
        .testTarget(
            name: "DependencyAnalyzerTests",
            dependencies: [
                "DependencyAnalyzer",
                .product(
                    name: "CustomDump",
                    package: "swift-custom-dump"
                ),
            ]
        ),
        .testTarget(
            name: "CodeGenerationTests",
            dependencies: [
                "CodeGeneration",
                "DependencyAnalyzer",
                "SourceModel",
                .product(
                    name: "CustomDump",
                    package: "swift-custom-dump"
                ),
            ]
        ),
    ]
)
