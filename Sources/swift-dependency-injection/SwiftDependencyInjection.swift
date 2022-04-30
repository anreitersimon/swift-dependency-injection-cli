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
    var graphFile: String?

    mutating func run() throws {
        let diagnostics = XcodeDiagnostics()

        try Generator.generateFactories(
            moduleName: moduleName,
            inputFile: URL(fileURLWithPath: inputFile),
            outputFile: URL(fileURLWithPath: outputFile),
            graphFile: graphFile.map { URL(fileURLWithPath: $0) },
            diagnostics: diagnostics
        )

        if diagnostics.hasErrors {
            throw ExitCode(1)
        }
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
        var graph = ModuleDependencyGraph(module: moduleName)
        // let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        inputFiles.forEach { path in
            //            let data = try Data(contentsOf: )
            //            let decoded = try decoder.decode(FileDependencyGraph.self, from: data)

            graph.files.append(URL(fileURLWithPath: path))
        }

        try Generator.generateModule(
            moduleGraph: graph,
            outputFile: URL(fileURLWithPath: outputFile)
        )

    }
}
