import DependencyModel
import Foundation
@_implementationOnly import SwiftSyntax

public enum DependencyAnalysis {

    public static func extractDependencyGraph(
        file: URL,
        moduleName: String
    ) throws -> DependencyGraph {
        let sourceFile = try SyntaxParser.parse(file)
        let scanner = SourceFileScanner(
            moduleName: moduleName,
            converter: SourceLocationConverter(
                file: file.absoluteString,
                tree: sourceFile
            )
        )
        scanner.walk(sourceFile)

        return scanner.dependencyGraph
    }
}
