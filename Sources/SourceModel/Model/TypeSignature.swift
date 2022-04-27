@_implementationOnly import SwiftSyntax

public indirect enum TypeSignature: Equatable, Codable {

    /// * `Type`
    case simple(name: String, genericArguments: [TypeSignature]? = nil)

    /// * `(Type1, Type2, ...)`
    /// * `(a: Type1, b: Type1, ...)`
    case tuple(raw: String)

    /// * `(Type1, Type2, ...) -> ReturnType`
    /// * `(label1: Type1, label2: Type2, ...) -> ReturnType`
    case function(raw: String)

    /// * `Type.self`
    case metatype(TypeSignature)

    /// * `[Key: Type]`
    case dictionary(key: TypeSignature, value: TypeSignature)

    /// * `[Element]`
    case array(TypeSignature)

    /// * `Element?`
    case optional(TypeSignature)

    /// * `Element!`
    case implicitlyUnwrappedOptional(TypeSignature)
    case attributed(TypeSignature)

    case unknown(type: String, value: String)
    case composition(raw: String)
    case memberType(raw: String)

    func inferLiteralTypes() -> Self {
        switch self {
        case .simple(let name, let genericArguments?):
            switch name {
            case "Optional", "Swift.Optional":
                if genericArguments.count == 1 {
                    return .optional(genericArguments[0])
                } else {
                    return self
                }

            case "Array", "Swift.Array":
                if genericArguments.count == 1 {
                    return .array(genericArguments[0])
                } else {
                    return self
                }

            case "Dictionary", "Swift.Dictionary":
                if genericArguments.count == 2 {
                    return .dictionary(
                        key: genericArguments[0],
                        value: genericArguments[1]
                    )
                } else {
                    return self
                }

            default:
                return self
            }

        default: return self
        }
    }

    static func fromTypeSyntax(_ type: TypeSyntax) -> TypeSignature {
        let typeProtocol = type.asProtocol(TypeSyntaxProtocol.self)

        switch typeProtocol {
        case let underlying as SimpleTypeIdentifierSyntax:

            return .simple(
                name: underlying.name.withoutTrivia().text,
                genericArguments: underlying.genericArgumentClause?.arguments
                    .map { arg in
                        .fromTypeSyntax(arg.argumentType)
                    }
            )

        case let underlying as MemberTypeIdentifierSyntax:
            return .memberType(raw: underlying.trimmed)

        case let underlying as MetatypeTypeSyntax:
            return .metatype(.fromTypeSyntax(underlying.baseType))

        case let underlying as TupleTypeSyntax:
            return .tuple(raw: underlying.trimmed)

        case let underlying as ArrayTypeSyntax:
            return .array(.fromTypeSyntax(underlying.elementType))

        case let underlying as DictionaryTypeSyntax:
            return .dictionary(
                key: .fromTypeSyntax(underlying.keyType),
                value: .fromTypeSyntax(underlying.valueType)
            )

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
