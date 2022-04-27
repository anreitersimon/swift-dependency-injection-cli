@_implementationOnly import SwiftSyntax

public struct Variable: Equatable, Codable {

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

    public let name: String
    public let type: TypeSignature?
    public var attributes: [String] = []
    public var modifiers: [Modifier] = []
    public var defaultValue: String? = nil
    public var isStored: Bool = true

}
