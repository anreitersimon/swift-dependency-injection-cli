import CodeGeneration
import DependencyAnalyzer
import DependencyModel
import Foundation

public struct Generator {

    public static func generateFactories(
        moduleName: String,
        inputFile: URL,
        outputFile: URL,
        graphFile: URL
    ) throws {
        let graph = try DependencyAnalysis.extractDependencyGraph(
            file: inputFile,
            moduleName: moduleName
        )

        try FileManager.default.createDirectory(
            at: outputFile.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        try FileManager.default.createDirectory(
            at: graphFile.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        print("warning: writing graph to \(graphFile.absoluteString)")
        try graph.write(to: graphFile)

        print("warning: generating factory methods at \(outputFile.absoluteString)")
        try CodeGen.generatedFactories(graph: graph).writeToFile(outputFile)
    }

    public static func generateModule(
        moduleName: String,
        mergedGraph: DependencyGraph,
        outputFile: URL
    ) throws {

        try FileManager.default.createDirectory(
            at: outputFile.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        try CodeGen
            .generateModule(moduleName: moduleName, graph: mergedGraph)
            .writeToFile(outputFile)
    }

}
