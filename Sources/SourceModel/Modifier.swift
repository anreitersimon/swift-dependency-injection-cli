
@_implementationOnly import SwiftSyntax

protocol ModifierProtocol: RawRepresentable where RawValue == String {}

extension Sequence where Element: ModifierProtocol {
    var accessLevel: AccessLevel {
        return
            self
            .compactMap { AccessLevel(rawValue: $0.rawValue) }
            .first ?? .internal
    }
}

extension Array where Element: ModifierProtocol {
    static func fromModifiers(_ modifiers: ModifierListSyntax?) -> Self {
        modifiers?.compactMap {
            Element(rawValue: $0.name.trimmed)
        } ?? []
    }
}
