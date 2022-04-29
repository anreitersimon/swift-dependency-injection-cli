import Foundation
@_implementationOnly import SwiftSyntax
@_implementationOnly import SwiftSyntaxParser

public struct SourceFile: Equatable, Codable, DeclarationScope {

    public init(
        fileName: String,
        module: String,
        imports: [Import] = [],
        types: [TypeDeclaration] = [],
        extensions: [Extension] = [],
        variables: [Variable] = [],
        functions: [Function] = [],
        initializers: [Initializer] = []
    ) {
        self.fileName = fileName
        self.module = module
        self.imports = imports
        self.types = types
        self.extensions = extensions
        self.variables = variables
        self.functions = functions
        self.initializers = initializers
    }

    var path: String { module }

    public let fileName: String
    public let module: String
    public var imports: [Import] = []
    public var types: [TypeDeclaration] = []
    public var extensions: [Extension] = []
    public var variables: [Variable] = []
    public var functions: [Function] = []
    public var initializers: [Initializer] = []

    public var recursiveTypes: [TypeDeclaration] {
        var builder: [TypeDeclaration] = []

        collectTypes(into: &builder)

        for ext in extensions {
            ext.collectTypes(into: &builder)
        }

        return builder
    }

}

extension DeclarationScope {

    func collectTypes(
        into collection: inout [TypeDeclaration]
    ) {
        for type in types {
            collection.append(type)
            type.collectTypes(into: &collection)
        }
    }

}

extension SourceFile {

    public static func parse(
        module: String,
        file: URL,
        includeSourceLocations: Bool = true
    ) throws -> SourceFile {
        let syntax = try SyntaxParser.parse(file)
        let context = Context(
            moduleName: module,
            fileName: file.deletingPathExtension().lastPathComponent,
            syntax: syntax,
            converter: includeSourceLocations
                ? SourceLocationConverter(
                    file: file.absoluteString,
                    tree: syntax
                ) : nil
        )

        let scanner = SourceFileScanner(context: context)
        scanner.walk(syntax)

        return scanner.sourceFile

    }
    public static func parse(
        module: String,
        fileName: String = "<in-memory>",
        source: String,
        includeSourceLocations: Bool = false
    ) throws -> SourceFile {
        let syntax = try SyntaxParser.parse(source: source)
        let context = Context(
            moduleName: module,
            fileName: fileName,
            syntax: syntax,
            converter: includeSourceLocations ? SourceLocationConverter(
                file: fileName,
                source: source
            ) : nil
        )

        let scanner = SourceFileScanner(context: context)
        scanner.walk(syntax)

        return scanner.sourceFile
    }
}
