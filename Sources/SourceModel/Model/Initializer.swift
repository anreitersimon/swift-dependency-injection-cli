public struct Initializer: Equatable, Codable {
    public enum Modifier: String, Codable, ModifierProtocol {
        case `public`
        case `private`
        case `fileprivate`
        case `internal`
        case `open`
    }

    public var accessLevel: AccessLevel {
        modifiers.accessLevel
    }

    public let modifiers: [Modifier]
    public let trailingModifiers: [Function.TrailingModifier]

    public var arguments: [Function.Argument] = []
}
