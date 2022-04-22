import DependencyModel
@_implementationOnly import SwiftSyntax

extension DeclGroupSyntax {
    func extractInitializers(context: Context) -> [Initializer] {
        let scanner = InitializerScanner(context: context)
        scanner.walk(members)
        return scanner.initializers
    }
}

/// Scans a TypeDeclaration for all Initializers
/// ```
/// class AClass {
///     init(name: String)
/// }
/// ```
class InitializerScanner: SyntaxVisitor {

    init(
        context: Context
    ) {
        self.context = context
    }

    let context: Context
    var initializers: [Initializer] = []

    override func visit(
        _ node: InitializerDeclSyntax
    ) -> SyntaxVisitorContinueKind {
        initializers.append(
            Initializer(
                arguments: node.extractArguments(context: context),
                range: node.sourceRange(context: context)
            )
        )
        return .skipChildren
    }

}
