@_implementationOnly import SwiftSyntax

public struct TypeDeclaration: Codable, Equatable, DeclarationScope {
    public let kind: Kind
    public let module: String
    public let name: String
    public let scope: String
    public let modifiers: [Modifier]
    public var generics: Generics = .empty
    public var inheritedTypes: [TypeSignature] = []

    public var initializers: [Initializer] = []
    public var variables: [Variable] = []
    public var functions: [Function] = []
    public var types: [TypeDeclaration] = []
    public let sourceRange: SourceRange?

    public var allAvailableInitializers: [Initializer] {
        if let i = implicitMemberwiseInitializer {
            return [i]
        } else {
            return self.initializers
        }
    }

    public var implicitMemberwiseInitializer: Initializer? {
        guard self.kind == .struct && self.initializers.isEmpty else {
            return nil
        }

        let storedVariables = self.variables.filter(\.isStored)

        return Initializer(
            arguments: storedVariables.map {
                Function.Argument(
                    firstName: $0.name,
                    secondName: nil,
                    type: $0.type,
                    attributes: $0.attributes,
                    defaultValue: $0.defaultValue,
                    sourceRange: $0.sourceRange
                )
            },
            sourceRange: self.sourceRange
        )
    }

    public enum Kind: String, Codable {
        case `struct`
        case `class`
        case `enum`
        case `protocol`
    }

    public enum Modifier: String, Codable, ModifierProtocol {
        case `public`
        case `private`
        case `fileprivate`
        case `internal`
        case `open`
        case `dynamic`
        case `final`
        case `indirect`
    }

    var path: String { name }

    public var fullyQualifiedName: String { "\(scope).\(name)" }
    public var accessLevel: AccessLevel { modifiers.accessLevel }
}

public struct Generics: Equatable, Codable {
    public let parameters: [Parameter]
    public let requirements: [Requirement]

    public var isEmpty: Bool {
        return parameters.isEmpty && requirements.isEmpty
    }

    public static let empty = Generics(parameters: [], requirements: [])

    public struct Requirement: Equatable, Codable {
        public let body: String
    }

    public struct Parameter: Equatable, Codable {
        public let name: String
        public let inheritedType: TypeSignature?
    }

    static func from(
        parameterClause: GenericParameterClauseSyntax?,
        whereClause: GenericWhereClauseSyntax?
    ) -> Generics {
        let params = parameterClause?.genericParameterList.map {
            Parameter(
                name: $0.name.trimmed,
                inheritedType: $0.inheritedType.map(TypeSignature.fromTypeSyntax(_:))
            )
        }

        let requirements = whereClause?.requirementList.map {
            Requirement(body: $0.body.trimmed)
        }

        return Generics(
            parameters: params ?? [],
            requirements: requirements ?? []
        )
    }
}
