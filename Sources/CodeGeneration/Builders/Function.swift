public struct Function: Writable {
    public let funcKeyword: String?
    public let name: String
    public let arguments: [Argument]
    public let returnType: String?
    public let modifiers: [String]
    public let trailingModifiers: [String]
    public let body: Writable?

    public static func initializer(
        arguments: [Argument],
        modifiers: [String] = [],
        trailingModifiers: [String] = [],
        @TextBuilder body: () -> Writable
    ) -> Function {
        Function(
            funcKeyword: nil,
            name: "init",
            arguments: arguments,
            returnType: nil,
            modifiers: modifiers,
            trailingModifiers: trailingModifiers,
            body: body
        )
    }

    public static func memberwiseInitializer(
        fields: [Variable]
    ) -> Function {

        Self.initializer(
            arguments: fields.map {
                Argument(firstName: $0.name, secondName: nil, type: $0.type)
            }
        ) {
            for field in fields {
                "self.\(field.name) = \(field.name)"
            }
        }
    }

    public init(
        funcKeyword: String? = "func",
        name: String,
        arguments: [Argument] = [],
        returnType: String? = nil,
        modifiers: [String],
        trailingModifiers: [String],
        @TextBuilder body: () -> Writable
    ) {
        self.funcKeyword = funcKeyword
        self.name = name
        self.arguments = arguments
        self.returnType = returnType
        self.modifiers = modifiers
        self.trailingModifiers = trailingModifiers
        self.body = body()
    }

    public init(
        funcKeyword: String? = "func",
        name: String,
        arguments: [Argument] = [],
        returnType: String? = nil,
        modifiers: [String],
        trailingModifiers: [String]
    ) {
        self.modifiers = modifiers
        self.funcKeyword = funcKeyword
        self.name = name
        self.arguments = arguments
        self.returnType = returnType
        self.trailingModifiers = trailingModifiers
        self.body = nil
    }

    public func write(to writer: FileWriter) {
        for modifier in modifiers {
            writer.write(modifier)
            writer.write(" ")
        }

        if let funcKeyword = funcKeyword {
            writer.write("\(funcKeyword) ")
        }
        writer.write("\(name)(")

        for (index, argument) in arguments.enumerated() {
            argument.write(to: writer)
            if index < arguments.count - 1 {
                writer.write(", ")
            }
        }

        writer.write(")")
        for trailingModifier in trailingModifiers {
            writer.write(" ")
            writer.write(trailingModifier)
        }
        if let returnType = returnType {
            writer.write(" -> \(returnType)")
        }
        if let body = body {
            writer.scope {
                body.write(to: $0)
            }
        }
    }

    public struct Argument: Writable {

        public let firstName: String
        public let secondName: String?
        public let type: String
        public let defaultValue: String?

        public init(
            firstName: String,
            secondName: String?,
            type: String,
            defaultValue: String? = nil
        ) {
            self.firstName = firstName
            self.secondName = secondName
            self.type = type
            self.defaultValue = defaultValue
        }

        public func write(to writer: FileWriter) {
            writer.write(firstName)
            if let label = secondName {
                writer.write(" ")
                writer.write(label)
            }

            writer.write(": \(type)")
            if let defaultValue = defaultValue {
                writer.write(" = \(defaultValue)")
            }
        }

        public func callWith(argument: String) -> String {
            if firstName == "_" {
                return argument
            } else {
                return "\(firstName): \(argument)"
            }
        }
    }
}
