public struct Extension: Equatable, Codable, DeclarationScope {
    var path: String { extendedType }

    let extendedType: String
    var initializers: [Initializer] = []
    var variables: [Variable] = []
    var functions: [Function] = []
    var types: [TypeDeclaration] = []

    init(
        extendedType: String,
        initializers: [Initializer] = [],
        variables: [Variable] = [],
        functions: [Function] = [],
        types: [TypeDeclaration] = []
    ) {
        self.extendedType = extendedType
        self.initializers = initializers
        self.variables = variables
        self.functions = functions
        self.types = types
    }

}
