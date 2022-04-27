@_implementationOnly import SwiftSyntax

struct Context {
    let moduleName: String
    let fileName: String
    let syntax: SourceFileSyntax
    let converter: SourceLocationConverter
}

extension SourceModel.SourceLocation {
    fileprivate init(swiftSyntaxLocation location: SwiftSyntax.SourceLocation) {
        self.init(
            line: location.line!,
            column: location.column!,
            file: location.file!
        )
    }
}
extension SyntaxProtocol {

    func sourceRange(context: Context) -> SourceModel.SourceRange {
        let range = self.sourceRange(converter: context.converter)

        return SourceModel.SourceRange(
            start: .init(swiftSyntaxLocation: range.start),
            end: .init(swiftSyntaxLocation: range.end)
        )
    }

    func startLocation(context: Context) -> SourceModel.SourceLocation {
        return .init(swiftSyntaxLocation: startLocation(converter: context.converter))
    }
}
