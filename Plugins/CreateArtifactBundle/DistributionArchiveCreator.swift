import Foundation
import PackagePlugin

@main
struct CreateArtifactBundle: CommandPlugin {

    struct Error: Swift.Error {
        let message: String
    }

    func performCommand(
        context: PluginContext,
        arguments: [String]
    ) throws {
        var extractor = ArgumentExtractor(arguments)

        let productArgs = extractor.extractOption(named: "product")
        let versionArgs = extractor.extractOption(named: "package-version")
        let archiveNameArgs = extractor.extractOption(named: "archive-name")

        let archiveName: String
        let version: String
        let products: [ExecutableProduct]

        guard archiveNameArgs.count <= 1 else {
            throw PluginError.tooManyArguments(name: "archive-name")
        }

        guard !versionArgs.isEmpty else {
            throw PluginError.missingRequiredArgument(name: "package-version")
        }

        guard versionArgs.count == 1 else {
            throw PluginError.tooManyArguments(name: "package-version")
        }

        version = versionArgs[0]
        archiveName = archiveNameArgs.first ?? "\(context.package.displayName)-\(version)"

        let outputPath = context.pluginWorkDirectory.appending("\(archiveName).zip")

        if productArgs.isEmpty {
            products = context.package.products(ofType: ExecutableProduct.self)
        } else {
            let matchingProducts = try context.package.products(named: productArgs)

            let executableProducts =
                matchingProducts
                .compactMap { $0 as? ExecutableProduct }
            let otherProducts =
                matchingProducts
                .filter { $0 is ExecutableProduct }

            products = executableProducts

            guard otherProducts.isEmpty else {
                throw PluginError.wrongProductType(products: otherProducts)
            }
        }

        guard !products.isEmpty else {
            throw PluginError.noProducts
        }

        var bundle = ArtifactBundle.Builder(
            url: URL(fileURLWithPath: context.pluginWorkDirectory.string)
                .appendingPathComponent(archiveName)
                .appendingPathExtension("artifactbundle"),
            version: version
        )

        try? FileManager.default.removeItem(atPath: outputPath.string)
        try? FileManager.default.removeItem(at: bundle.url)

        for product in products {
            // Ask the plugin host (SwiftPM or an IDE) to build our product.
            let result = try packageManager.build(
                .product(product.name),
                parameters: .init(configuration: .release, logging: .concise)
            )

            guard result.succeeded else {
                throw PluginError.buildProductFailed(name: product.name, result: result)
            }

            for artifact in result.builtArtifacts {
                try bundle.addArtifact(artifact)
            }
        }

        try bundle.save()

        let zip = try context.tool(named: "zip")

        let process = Process()
        process.executableURL = URL(fileURLWithPath: zip.path.string)
        process.currentDirectoryURL = bundle.url.deletingLastPathComponent()
        process.arguments = [
            "-r", "-qq", outputPath.string, bundle.url.lastPathComponent,
        ]

        try process.run()

        process.waitUntilExit()

        // Check whether the subprocess invocation was successful.
        if process.terminationReason == .exit && process.terminationStatus == 0 {
            print(outputPath.string)
        } else {

            throw PluginError.createZipArchiveFailed(
                "\(process.terminationReason):\(process.terminationStatus)"
            )
        }
    }
}

enum PluginError: Error, CustomStringConvertible {
    case tooManyArguments(name: String)
    case missingRequiredArgument(name: String)
    case wrongProductType(products: [Product])
    case buildProductFailed(name: String, result: PackageManager.BuildResult)
    case createZipArchiveFailed(String)
    case noProducts

    var description: String {
        switch self {
        case .tooManyArguments(let name):
            return "Too many value provided for \"\(name)\""
        case .missingRequiredArgument(let name):
            return "No value provided for \"\(name)\""
        case .wrongProductType(let products):
            return """
                Unsupported product (only executable products supported)
                Invalid products: \(products.map(\.name).joined(separator: ", "))
                """
        case .buildProductFailed(let name, let result):
            return """
                Failed to build \(name)

                \(result.logText)
                """

        case .noProducts:
            return "No products to build"

        case .createZipArchiveFailed(let problem):
            return """
                Failed to create zip archive

                \(problem)
                """
        }
    }
}
