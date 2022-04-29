public struct Extension: Equatable, Codable, DeclarationScope {
    public let extendedType: String

    public var initializers: [Initializer] = []
    public var variables: [Variable] = []
    public var functions: [Function] = []
    public var types: [TypeDeclaration] = []

    public let scope: String
    public let modifiers: [Modifier]
    public var generics: Generics = .empty
    public var inheritedTypes: [TypeSignature] = []
    public let sourceRange: SourceRange?

    public enum Modifier: String, Codable, ModifierProtocol {
        case `public`
        case `private`
        case `fileprivate`
        case `internal`
    }

    var path: String { extendedType }

    public var fullyQualifiedName: String { "\(scope).\(extendedType)" }
    public var accessLevel: AccessLevel { modifiers.accessLevel }
}
