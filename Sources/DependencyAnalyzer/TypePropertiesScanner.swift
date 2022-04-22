import Foundation
@_implementationOnly import SwiftSyntax
import DependencyModel


extension DeclGroupSyntax {
    func extractStoredProperties(context: Context) -> [Parameter] {

        let scanner = StoredPropertiesScanner(context: context)

        scanner.walk(members)

        return scanner.arguments

    }
}

class StoredPropertiesScanner: SyntaxVisitor {

    init(
        context: Context
    ) {
        self.context = context
    }

    let context: Context
    var arguments: [Parameter] = []

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        return .skipChildren
    }

    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {

        guard
            let binding = node.bindings.first,
            let pattern = binding.pattern.as(IdentifierPatternSyntax.self),
            node.bindings.count == 1,
            let typeName = binding.typeAnnotation?.type.withoutTrivia().description
        else {
            return .skipChildren
        }

        let name = pattern.identifier.withoutTrivia().text

        let attributes =
            node.attributes?
            .compactMap { $0.as(CustomAttributeSyntax.self) }
            .map { $0.attributeName.withoutTrivia().description }

        self.arguments.append(
            Parameter(
                type: TypeDescriptor(name: typeName),
                firstName: name,
                secondName: nil,
                attributes: attributes ?? [],
                range: node.sourceRange(context: context)
            )
        )

        return .skipChildren
    }

}

extension VariableDeclSyntax {

    func extractArgument(context: Context) throws -> Parameter? {

        guard
            let binding = bindings.first,
            let pattern = binding.pattern.as(IdentifierPatternSyntax.self),
            bindings.count == 1
        else {
            return nil
        }

        guard binding.accessor == nil else {
            return nil
        }

        guard
            let typeName = binding.typeAnnotation?.type.withoutTrivia().description
        else {
            throw VariableDeclarationError.typeAnnotationRequired(
                binding.sourceRange(context: context)
            )
        }

        let name = pattern.identifier.withoutTrivia().text

        let attributes =
            attributes?
            .compactMap { $0.as(CustomAttributeSyntax.self) }
            .map { $0.attributeName.withoutTrivia().description }

        return Parameter(
            type: TypeDescriptor(name: typeName),
            firstName: name,
            secondName: nil,
            attributes: attributes ?? [],
            range: binding.sourceRange(context: context)
        )
    }

}

enum VariableDeclarationError: LocalizedError {
    case typeAnnotationRequired(DependencyModel.SourceRange)
}
