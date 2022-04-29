@_implementationOnly import SwiftSyntax

struct Context {
    let moduleName: String
    let fileName: String
    let syntax: SourceFileSyntax
    let converter: SourceLocationConverter?
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

    func sourceRange(context: Context) -> SourceModel.SourceRange? {
        guard let converter = context.converter else {
            return nil
        }
        let range = self.sourceRange(converter: converter)

        return SourceModel.SourceRange(
            start: .init(swiftSyntaxLocation: range.start),
            end: .init(swiftSyntaxLocation: range.end)
        )
    }

}
