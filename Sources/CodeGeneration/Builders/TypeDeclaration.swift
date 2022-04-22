public struct TypeDeclaration: Writable {

    public let kind: String
    public let name: String
    public let body: Writable
    public let accessLevel: String?

    public init(
        kind: String,
        name: String,
        accessLevel: String?,
        @TextBuilder body: @escaping () -> Writable
    ) {
        self.kind = kind
        self.name = name
        self.accessLevel = accessLevel
        self.body = body()
    }

    public func write(to writer: FileWriter) {
        if let accessLevel = accessLevel {
            writer.write(accessLevel)
            writer.write(" ")
        }
        writer.write("\(kind) \(name)")
        writer.scope {
            body.write(to: $0)
        }
    }
}
