import CodeGeneration
import DependencyAnalyzer
import DependencyModel
import Foundation
import SourceModel

public class XcodeDiagnostics: Diagnostics {
    public init() {}

    public var hasErrors: Bool = false

    public func record(_ diagnostic: Diagnostic) {
        if diagnostic.level == .error {
            hasErrors = true
        }
        print(diagnostic.description)
    }
}

public struct Generator {

    public static func generateFactories(
        moduleName: String,
        inputFile: URL,
        outputFile: URL,
        graphFile: URL?,
        diagnostics: Diagnostics
    ) throws {
        // TODO
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

        if let graphFile = graphFile {
            let encoded = try JSONEncoder().encode(fileGraph)

            try FileManager.default.smartWrite(
                encoded,
                to: graphFile
            )
        }

    }

    public static func generateModule(
        moduleGraph: ModuleDependencyGraph,
        outputFile: URL
    ) throws {

        let contents = CodeGen.generateSources(moduleGraph: moduleGraph)
        try FileManager.default.smartWrite(
            contents.data(using: .utf8)!,
            to: outputFile
        )

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
