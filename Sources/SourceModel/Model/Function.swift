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

    public struct Argument: Equatable, Codable {
        var firstName: String?
        var secondName: String?
        var type: TypeSignature?
        var attributes: [String] = []
        var defaultValue: String? = nil
    }
}
