import Foundation
@_implementationOnly import SwiftSyntax
@_implementationOnly import SwiftSyntaxParser

public struct SourceFile: Equatable, Codable, DeclarationScope {
    var path: String { module }

    public let module: String
    public var imports: [Import] = []
    public var types: [TypeDeclaration] = []
    public var extensions: [Extension] = []
    public var variables: [Variable] = []
    public var functions: [Function] = []
    public var initializers: [Initializer] = []
}

extension SourceFile {

    public static func parse(
        module: String,
        file: URL
    ) throws -> SourceFile {
        let syntax = try SyntaxParser.parse(file)
        let context = Context(
            moduleName: module,
            syntax: syntax,
            converter: SourceLocationConverter(
                file: file.absoluteString,
                tree: syntax
            )
        )

        let scanner = SourceFileScanner(context: context)
        scanner.walk(syntax)

        return scanner.sourceFile

    }
    public static func parse(
        module: String,
        fileName: String = "<in-memory>",
        source: String
    ) throws -> SourceFile {
        let syntax = try SyntaxParser.parse(source: source)
        let context = Context(
            moduleName: module,
            syntax: syntax,
            converter: SourceLocationConverter(
                file: fileName,
                source: source
            )
        )

        let scanner = SourceFileScanner(context: context)
        scanner.walk(syntax)

        return scanner.sourceFile
    }
}
