import CodeGeneration
import DependencyAnalyzer
import DependencyModel
import Foundation
import SourceModel

class XcodeDiagnostics: Diagnostics {
    func record(_ diagnostic: Diagnostic) {
        print(diagnostic.description)
    }
}

public struct Generator {

    public static func generateFactories(
        moduleName: String,
        inputFile: URL,
        outputFile: URL,
        graphFile: URL
    ) throws {
        // TODO
        let diagnostics = XcodeDiagnostics()

        let sourceFile = try SourceFile.parse(
            module: moduleName,
            file: inputFile
        )

        let fileGraph = try DependencyAnalysis.extractGraph(
            file: sourceFile,
            diagnostics: diagnostics
        )

        let contents = CodeGen.generateSources(
            fileGraph: fileGraph
        )

        try FileManager.default.smartWrite(
            contents.data(using: .utf8)!,
            to: outputFile
        )
        
        let encoded = try JSONEncoder().encode(fileGraph)

        try FileManager.default.smartWrite(
            encoded,
            to: graphFile
        )

    }

    public static func generateModule(
        moduleName: String,
        mergedGraph: ModuleDependencyGraph,
        outputFile: URL
    ) throws {
        // TODO
    }

}

extension FileManager {
    func smartWrite(
        _ contents: Data,
        to url: URL
    ) throws {
        if fileExists(atPath: url.path) {
            try self.removeItem(at: url)
        }
        try self.createDirectory(
            at: url.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        try contents.write(to: url, options: .atomic)

    }
}
