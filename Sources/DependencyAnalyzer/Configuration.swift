import DependencyModel
@_implementationOnly import SwiftSyntax

struct Context {
    let moduleName: String
    let converter: SourceLocationConverter
}
extension DependencyModel.SourceLocation {
    fileprivate init(swiftSyntaxLocation location: SwiftSyntax.SourceLocation) {
        self.init(
            line: location.line!,
            column: location.column!,
            file: location.file!
        )
    }
}
extension SyntaxProtocol {

    func sourceRange(context: Context) -> DependencyModel.SourceRange {
        let range = self.sourceRange(converter: context.converter)

        return DependencyModel.SourceRange(
            start: .init(swiftSyntaxLocation: range.start),
            end: .init(swiftSyntaxLocation: range.end)
        )
    }
    
    func startLocation(context: Context) -> DependencyModel.SourceLocation {
        return .init(swiftSyntaxLocation: startLocation(converter: context.converter))
    }
}
