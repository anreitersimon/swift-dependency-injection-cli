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
    public let type: VariableType?
    public let attributes: [String]
    public let modifiers: [Modifier]
    public let isStored: Bool

    public indirect enum VariableType: Equatable, Codable {
        case simple(String)
        case optional(VariableType)
        case implicitlyUnwrappedOptional(VariableType)
        case unknown(type: String, value: String)

        static func fromTypeSyntax(_ type: TypeSyntax) -> VariableType {
            let typeProtocol = type.asProtocol(TypeSyntaxProtocol.self)
            switch typeProtocol {
            case let underlying as SimpleTypeIdentifierSyntax:
                return .simple(underlying.name.withoutTrivia().text)
            case let underlying as OptionalTypeSyntax:
                return .optional(.fromTypeSyntax(underlying.wrappedType))
            case let underlying as ImplicitlyUnwrappedOptionalTypeSyntax:
                return .implicitlyUnwrappedOptional(.fromTypeSyntax(underlying.wrappedType))
            default:
                return .unknown(
                    type: "\(type.syntaxNodeType)",
                    value: type.trimmed
                )
            }
        }
    }
}
