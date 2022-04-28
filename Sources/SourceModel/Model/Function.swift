public struct Function: Equatable, Codable {

    public enum Modifier: String, Codable, ModifierProtocol {
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

    public enum TrailingModifier: String, Codable, ModifierProtocol {
        case `throws`, `rethrows`, `async`
    }

    public var accessLevel: AccessLevel { modifiers.accessLevel }
    public let arguments: [Argument]
    public let modifiers: [Modifier]
    public let trailingModifiers: [TrailingModifier]

    public struct Argument: Equatable, Codable, CustomStringConvertible {
        public var firstName: String?
        public var secondName: String?
        public var type: TypeSignature?
        public var attributes: [String] = []
        public var defaultValue: String? = nil

        public var description: String {
            var builder = [
                firstName, secondName,
            ]
            .compactMap { $0 }
            .joined(separator: " ")

            builder.append(": ")
            if let type = type {
                builder.append(type.description)
            }

            if let defaultValue = defaultValue {
                builder.append(" = \(defaultValue)")
            }

            return builder
        }

        public var callSiteName: String? {
            if firstName == "_" {
                return nil
            } else {
                return firstName
            }
        }
    }
}
