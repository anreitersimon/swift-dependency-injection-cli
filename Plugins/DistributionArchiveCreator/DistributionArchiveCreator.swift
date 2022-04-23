import Foundation
import PackagePlugin

struct ArtifactBundle: Codable {

    struct Artifact: Codable {
        var version: String
        var type: String
        var variants: [Variant]

        struct Variant: Codable {
            var path: String
            var supportedTriples: [String]
        }
    }

    struct Info: Codable {
        var schemaVersion = "1.0"
        var artifacts: [String: Artifact]
    }
}

@main
struct DistributionArchiveCreator: CommandPlugin {

    struct Error: Swift.Error {
        let message: String
    }

    func performCommand(
        context: PluginContext,
        arguments: [String]
    ) async throws {
        // Check that we were given the name of a product as the first argument
        // and the name of an archive as the second.
        guard arguments.count == 3 else {
            throw Error(message: "Expected two arguments: product-name  archive-name version")
        }
        let productName = arguments[0]
        let archiveName = arguments[1]
        let version = arguments[2]
        
        print("building \(productName)")

        // Ask the plugin host (SwiftPM or an IDE) to build our product.
        let result = try await packageManager.build(
            .product(productName),
            parameters: .init(configuration: .release, logging: .debug)
        )

        // Check the result. Ideally this would report more details.
        guard result.succeeded else {
            throw Error(message: "couldn't build product")
        }

        // Get the list of built executables from the build result.
        let builtExecutables = result.builtArtifacts.filter { $0.kind == .executable }

        // Decide on the output path for the archive.
        let outputPath = context.pluginWorkDirectory.appending("\(archiveName).zip")

        let artifactBundle = URL(fileURLWithPath: context.pluginWorkDirectory.string)
            .appendingPathComponent(archiveName)
            .appendingPathExtension("artifactbundle")

        try? FileManager.default.removeItem(at: artifactBundle)

        try FileManager.default.createDirectory(
            at: artifactBundle,
            withIntermediateDirectories: true
        )

        var info = ArtifactBundle.Info(artifacts: [:])

        for executable in builtExecutables {
            let name = executable.path.stem
            let path = "\(name)-\(version)-macos/bin/\(name)"
            let url = artifactBundle.appendingPathComponent(path)

            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )

            try FileManager.default.copyItem(
                at: URL(fileURLWithPath: executable.path.string),
                to: url
            )

            info.artifacts[name] = ArtifactBundle.Artifact(
                version: version,
                type: "executable",
                variants: [
                    .init(
                        path: path,
                        supportedTriples: [
                            "x86_64-apple-macosx",
                            "arm64-apple-macosx",
                        ]
                    )
                ]
            )
        }
        
        let encoder = JSONEncoder()
        
        let data = try encoder.encode(info)
        
        try data.write(to: artifactBundle.appendingPathComponent("info.json"))
        
        print("created bundle at \(artifactBundle.absoluteString)")
    }
}
