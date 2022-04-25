import DependencyModel
import Foundation
@_implementationOnly import SwiftSyntax

protocol Scope {}

protocol ModifierProtocol: RawRepresentable where RawValue == String {}

extension Sequence where Element: ModifierProtocol {
    var accessLevel: SourceCode.AccessLevel {
        return
            self
            .compactMap { SourceCode.AccessLevel(rawValue: $0.rawValue) }
            .first ?? .internal
    }
}

extension Array where Element: ModifierProtocol {
    static func fromModifiers(_ modifiers: ModifierListSyntax?) -> Self {
        modifiers?.compactMap {
            Element(rawValue: $0.name.trimmed)
        } ?? []
    }
}

extension SyntaxProtocol {

    var trimmed: String {
        withoutTrivia().description
    }
}

protocol TypeDeclarationScope: Scope {
    var types: [SourceCode.TypeDeclaration] { get nonmutating set }
}

protocol MemberDeclarationScope: TypeDeclarationScope {
    var initializers: [SourceCode.Initializer] { get nonmutating set }
    var properties: [SourceCode.Variable] { get nonmutating set }
    var functions: [SourceCode.Function] { get nonmutating set }
    var types: [SourceCode.TypeDeclaration] { get nonmutating set }
}

class SourceCode: TypeDeclarationScope {

    var imports: [Import] = []
    var types: [TypeDeclaration] = []
    var extensions: [Extension] = []

    struct Import: Hashable {
        let modifers: [String]?
        let attributes: [String]?
        let kind: TypeDeclaration.Kind?
        let path: String
    }

    enum AccessLevel: String {
        case `public`
        case `private`
        case `fileprivate`
        case `internal`
        case `open`
    }

    class TypeDeclaration: MemberDeclarationScope {

        enum Modifier: String, ModifierProtocol {
            case `public`
            case `private`
            case `fileprivate`
            case `internal`
            case `open`
            case `dynamic`
            case `final`
            case `indirect`
        }

        init(
            module: String,
            name: String,
            kind: SourceCode.TypeDeclaration.Kind,
            modifiers: [Modifier],
            initializers: [SourceCode.Initializer] = [],
            properties: [SourceCode.Variable] = [],
            functions: [SourceCode.Function] = [],
            types: [SourceCode.TypeDeclaration] = []
        ) {
            self.module = module
            self.name = name
            self.kind = kind
            self.modifiers = modifiers
            self.initializers = initializers
            self.properties = properties
            self.functions = functions
            self.types = types
        }

        enum Kind: String {
            case `struct`
            case `class`
            case `enum`
            case `protocol`
        }

        let module: String
        let name: String
        let kind: Kind
        let modifiers: [Modifier]

        var initializers: [Initializer] = []
        var properties: [Variable] = []
        var functions: [Function] = []
        var types: [TypeDeclaration] = []
    }

    class Extension: MemberDeclarationScope {

        let extendedType: String
        var initializers: [Initializer] = []
        var properties: [Variable] = []
        var functions: [Function] = []
        var types: [TypeDeclaration] = []

        init(
            extendedType: String,
            initializers: [SourceCode.Initializer] = [],
            properties: [SourceCode.Variable] = [],
            functions: [SourceCode.Function] = [],
            types: [SourceCode.TypeDeclaration] = []
        ) {
            self.extendedType = extendedType
            self.initializers = initializers
            self.properties = properties
            self.functions = functions
            self.types = types
        }

    }

    struct Variable {
        enum Modifier: String, ModifierProtocol {
            case `public`
            case `private`
            case `fileprivate`
            case `internal`
            case `open`

            case `static`
            case `class`

            case `weak`
            case `unowned`

            case `mutating`
        }

        let name: String
        let type: VariableType?
        let attributes: [String]?
        let modifiers: [Modifier]
        let isStored: Bool

        enum VariableType {
            case simple(String)
            case unknown(String)
        }
    }

    struct Function {
        enum Modifier: String {
            case `public`
            case `private`
            case `fileprivate`
            case `internal`
            case `open`

            case `static`
            case `class`

            case `weak`
            case `unowned`

            case `mutating`
        }

        enum TrailingModifier: String, CaseIterable {
            case `throws`, `rethrows`, `async`
        }

        let accessLevel: AccessLevel
        let arguments: [Argument]
        let modifiers: [Modifier]
        let trailingModifiers: [TrailingModifier]

        struct Argument {
            let firstName: String?
            let secondName: String?
            let attributes: [String]?
            let defaultValue: String?
        }
    }

    struct Initializer {
        enum Modifier: String, ModifierProtocol {
            case `public`
            case `private`
            case `fileprivate`
            case `internal`
            case `open`
        }

        var accessLevel: AccessLevel {
            modifiers.accessLevel
        }

        let modifiers: [Modifier]
        let trailingModifiers: Set<Function.TrailingModifier>

        var arguments: [Function.Argument] = []
    }
}

class SourceFileScanner: SyntaxVisitor {
    let context: Context
    var imports: [String] = []
    private var namespace: [String] = []
    var sourceFile = SourceCode()

    var dependencyGraph = DependencyGraph()

    /// stack of type declarations to keep track of the current scope
    lazy var scopes: [TypeDeclarationScope] = [sourceFile]

    var typeDeclarationScope: TypeDeclarationScope { scopes.last! }
    var memberDeclarationScope: MemberDeclarationScope? {
        scopes.compactMap { $0 as? MemberDeclarationScope }.last
    }

    init(
        context: Context
    ) {
        self.context = context
    }

    var currentTypeName: String {
        return namespace.joined(separator: ".")
    }

    override func visitPost(_ node: ImportDeclSyntax) {

        sourceFile.imports.append(
            .init(
                modifers: node.modifiers?.map {
                    $0.withoutTrivia().description
                },
                attributes: node.attributes?.map {
                    $0.withoutTrivia().description
                },
                kind: node.importKind.map {
                    SourceCode.TypeDeclaration.Kind(rawValue: $0.text)!
                },
                path: node.path.withoutTrivia().description
            )
        )

        self.imports.append(node.withoutTrivia().description)
    }

    override func visit(_ node: CodeBlockSyntax) -> SyntaxVisitorContinueKind {
        print("Skipping CodeBlockSyntax")
        return .skipChildren
    }

    override func visit(
        _ node: InitializerDeclSyntax
    ) -> SyntaxVisitorContinueKind {

        var initializer = SourceCode.Initializer(
            modifiers: .fromModifiers(node.modifiers),
            trailingModifiers: []
        )

        for parameter in node.parameters.parameterList {
            initializer.arguments.append(
                SourceCode.Function.Argument(
                    firstName: parameter.firstName?.text,
                    secondName: parameter.secondName?.text,
                    attributes: parameter.attributes?.map {
                        $0.trimmed
                    },
                    defaultValue: parameter.defaultArgument?.value.trimmed
                )
            )
        }

        assert(memberDeclarationScope != nil)

        memberDeclarationScope?.initializers.append(initializer)

        return .skipChildren
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {

        let typeDecl = SourceCode.TypeDeclaration(
            module: context.moduleName,
            name: node.identifier.trimmed,
            kind: .class,
            modifiers: .fromModifiers(node.modifiers)
        )

        scopes.append(typeDecl)

        return .visitChildren
    }

    override func visitPost(_ node: ClassDeclSyntax) {
        let typeDecl = scopes.removeLast() as! SourceCode.TypeDeclaration

        typeDeclarationScope.types.append(typeDecl)
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {

        let typeDecl = SourceCode.TypeDeclaration(
            module: context.moduleName,
            name: node.identifier.trimmed,
            kind: .struct,
            modifiers: .fromModifiers(node.modifiers)
        )

        scopes.append(typeDecl)

        return .visitChildren
    }

    override func visitPost(_ node: StructDeclSyntax) {
        let typeDecl = scopes.removeLast() as! SourceCode.TypeDeclaration

        typeDeclarationScope.types.append(typeDecl)
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {

        let typeDecl = SourceCode.TypeDeclaration(
            module: context.moduleName,
            name: node.identifier.trimmed,
            kind: .struct,
            modifiers: .fromModifiers(node.modifiers)
        )

        scopes.append(typeDecl)

        return .visitChildren
    }

    override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        let typeDecl = SourceCode.Extension(
            extendedType: node.extendedType.withoutTrivia().description
        )

        scopes.append(typeDecl)
        return .visitChildren
    }

    override func visitPost(_ node: ExtensionDeclSyntax) {
        let typeDecl = scopes.removeLast() as! SourceCode.Extension

        sourceFile.extensions.append(typeDecl)
    }

    override func visitPost(_ node: EnumDeclSyntax) {
        let typeDecl = scopes.removeLast() as! SourceCode.TypeDeclaration

        typeDeclarationScope.types.append(typeDecl)
    }

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        .skipChildren
    }

    override func visit(
        _ node: VariableDeclSyntax
    ) -> SyntaxVisitorContinueKind {
        guard let memberDeclarationScope = memberDeclarationScope else {
            return .skipChildren
        }

        guard let binding = node.bindings.first else {
            return .skipChildren
        }
        let name = binding.pattern.withoutTrivia().description
        let isStored = binding.accessor == nil

        let variableType: SourceCode.Variable.VariableType?

        if let type = binding.typeAnnotation?.type {
            let typeProtocol = type.asProtocol(TypeSyntaxProtocol.self)

            switch typeProtocol {
            case let simple as SimpleTypeIdentifierSyntax:
                variableType = .simple(simple.name.withoutTrivia().text)
            default:
                variableType = .unknown(type.withoutTrivia().description)
            }
        } else {
            variableType = nil
        }

        memberDeclarationScope.properties.append(
            SourceCode.Variable(
                name: name,
                type: variableType,
                attributes: [],
                modifiers: .fromModifiers(node.modifiers),
                isStored: isStored
            )
        )
        return .skipChildren
    }

}

extension TypeInheritanceClauseSyntax {

    var hasInjectableConformance: Bool {
        return inheritedTypeCollection.contains {
            let typeName = $0.typeName.withoutTrivia().description

            return [
                "Injectable", "DependencyInjection.Injectable",
            ].contains(typeName)
        }
    }

}
