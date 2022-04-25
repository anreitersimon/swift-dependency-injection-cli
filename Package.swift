// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-dependency-injection-cli",
    products: [
        .executable(
            name: "swift-dependency-injection",
            targets: ["swift-dependency-injection"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/anreitersimon/swift-package-utils",
            branch: "main"
        ),
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            revision: "0.50500.0"
        ),
        .package(
            url: "https://github.com/apple/swift-argument-parser",
            from: "1.0.0"
        ),
    ],
    targets: [
        .binaryTarget(
            name: "lib_InternalSwiftSyntaxParser",
            url:
                "https://github.com/keith/StaticInternalSwiftSyntaxParser/releases/download/5.5.2/lib_InternalSwiftSyntaxParser.xcframework.zip",
            checksum: "96bbc9ab4679953eac9ee46778b498cb559b8a7d9ecc658e54d6679acfbb34b8"
        ),
        .executableTarget(
            name: "swift-dependency-injection",
            dependencies: [
                "lib_InternalSwiftSyntaxParser",
                "DependencyInjectionKit",
                .product(
                    name: "ArgumentParser",
                    package: "swift-argument-parser"
                ),
            ]
        ),
        .target(name: "DependencyModel"),
        .target(
            name: "DependencyAnalyzer",
            dependencies: [
                .product(
                    name: "SwiftSyntax",
                    package: "swift-syntax"
                ),
                "DependencyModel",
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
    ]
)
