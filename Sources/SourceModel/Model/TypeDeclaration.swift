public struct TypeDeclaration: Codable, Equatable, DeclarationScope {

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

    init(
        module: String,
        name: String,
        kind: TypeDeclaration.Kind,
        modifiers: [Modifier],
        initializers: [Initializer] = [],
        properties: [Variable] = [],
        functions: [Function] = [],
        types: [TypeDeclaration] = []
    ) {
        self.module = module
        self.name = name
        self.kind = kind
        self.modifiers = modifiers
        self.initializers = initializers
        self.variables = properties
        self.functions = functions
        self.types = types
    }

    public enum Kind: String, Codable {
        case `struct`
        case `class`
        case `enum`
        case `protocol`
    }

    public let module: String
    public let name: String
    public let kind: Kind
    public let modifiers: [Modifier]

    public var initializers: [Initializer] = []
    public var variables: [Variable] = []
    public var functions: [Function] = []
    public var types: [TypeDeclaration] = []

    var path: String { name }
}
