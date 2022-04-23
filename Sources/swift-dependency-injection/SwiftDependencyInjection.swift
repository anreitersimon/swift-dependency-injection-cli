import ArgumentParser
import DependencyInjectionKit
import DependencyModel
import Foundation

@main struct SwiftDependencyInjection: ParsableCommand {
    static let configuration = CommandConfiguration(subcommands: [
        Extract.self,
        Merge.self,
    ])
}

struct Extract: ParsableCommand {

    @Option
    var moduleName: String

    @Option
    var inputFile: String

    @Option
    var outputFile: String

    @Option
    var graphFile: String

    mutating func run() throws {
        try Generator.generateFactories(
            moduleName: moduleName,
            inputFile: URL(fileURLWithPath: inputFile),
            outputFile: URL(fileURLWithPath: outputFile),
            graphFile: URL(fileURLWithPath: graphFile)
        )
    }
}

struct Merge: ParsableCommand {

    @Option(parsing: .upToNextOption)
    var inputFiles: [String]

    @Option
    var moduleName: String

    @Option
    var outputFile: String

    mutating func run() throws {
        var graph = DependencyGraph()
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        try inputFiles.forEach { path in

            print("w: Merging \(path)")

            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let decoded = try decoder.decode(DependencyGraph.self, from: data)

            graph.merge(decoded)
        }

        try Generator.generateModule(
            moduleName: moduleName,
            mergedGraph: graph,
            outputFile: URL(fileURLWithPath: outputFile)
        )

    }
}
