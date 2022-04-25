import DependencyModel
import Foundation
@_implementationOnly import SwiftSyntax
@_implementationOnly import SwiftSyntaxParser

public enum DependencyAnalysis {

    public static func extractDependencyGraph(
        file: URL,
        moduleName: String
    ) throws -> DependencyGraph {
        let sourceFile = try SyntaxParser.parse(file)
        let context = Context(
            moduleName: moduleName,
            syntax: sourceFile,
            converter: SourceLocationConverter(file: file.absoluteString, tree: sourceFile)
        )
        let scanner = SourceFileScanner(context: context)
        scanner.walk(sourceFile)

        return scanner.dependencyGraph
    }
}
