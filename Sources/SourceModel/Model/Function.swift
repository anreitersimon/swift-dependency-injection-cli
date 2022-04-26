public struct Function: Equatable, Codable {
    public enum Modifier: String, Codable {
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

    public enum TrailingModifier: String, Codable {
        case `throws`, `rethrows`, `async`
    }

    public let accessLevel: AccessLevel
    public let arguments: [Argument]
    public let modifiers: [Modifier]
    public let trailingModifiers: [TrailingModifier]

    public struct Argument: Equatable, Codable {
        let firstName: String?
        let secondName: String?
        let type: String?
        let attributes: [String]
        let defaultValue: String?
    }
}
