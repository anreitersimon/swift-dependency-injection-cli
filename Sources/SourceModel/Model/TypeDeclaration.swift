import SwiftSyntax

public struct TypeDeclaration: Codable, Equatable, DeclarationScope {
    public let kind: Kind
    public let module: String
    public let name: String
    public let scope: String
    public let modifiers: [Modifier]
    public var generics: Generics = Generics(parameters: [], requirements: [])
    public var inheritedTypes: [TypeSignature] = []

    public var initializers: [Initializer] = []
    public var variables: [Variable] = []
    public var functions: [Function] = []
    public var types: [TypeDeclaration] = []

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
