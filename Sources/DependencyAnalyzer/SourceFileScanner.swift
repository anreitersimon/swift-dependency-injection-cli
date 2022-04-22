import DependencyModel
import Foundation
@_implementationOnly import SwiftSyntax

class SourceFileScanner: SyntaxVisitor {
    let context: Context
    var imports: [String] = []
    private var namespace: [String] = []
    var dependencyGraph = DependencyGraph()

    init(moduleName: String, converter: SourceLocationConverter) {
        self.context = Context(moduleName: moduleName, converter: converter)
    }

    var currentTypeName: String {
        return namespace.joined(separator: ".")
    }

    override func visitPost(_ node: ImportDeclSyntax) {
        self.imports.append(node.withoutTrivia().description)
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {

        namespace.append(node.identifier.withoutTrivia().description)

        // Check if class inherits `Injectable` marker protocol
        guard node.inheritanceClause?.hasInjectableConformance ?? false else {
            return .skipChildren
        }

        let initializers = node.extractInitializers(context: context)
        let storedProperties = node.extractStoredProperties(context: context)

        let arguments: [Parameter]

        if initializers.count == 1 {
            // explicit initializer found
            arguments = initializers[0].arguments
        } else if initializers.count == 0, storedProperties.count == 0 {
            // we can use the implicit initializer
            arguments = []
        } else if initializers.count > 0 {
            arguments = initializers[0].arguments

            print("warning: Multiple Initializers found for \(currentTypeName)")
        } else {
            print("error: No Initializer found for \(currentTypeName)")
            return .skipChildren
        }

        self.dependencyGraph.imports.formUnion(imports)

        self.dependencyGraph.provides.append(
            ProvidedDependency(
                location: node.startLocation(context: context),
                type: TypeDescriptor(name: currentTypeName),
                kind: .injectable,
                arguments: arguments
            )
        )

        dependencyGraph.uses.append(
            Injection(
                range: node.sourceRange(context: context),
                arguments: arguments
            )
        )

        return .skipChildren
    }

    override func visitPost(_ node: ClassDeclSyntax) {
        namespace.removeLast()
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {

        namespace.append(node.identifier.withoutTrivia().description)

        // Check if class inherits `Injectable` marker protocol
        guard node.inheritanceClause?.hasInjectableConformance ?? false else {
            return .skipChildren
        }

        let initializers = node.extractInitializers(context: context)
        let storedProperties = node.extractStoredProperties(context: context)

        let arguments: [Parameter]

        if initializers.count > 1 {
            print(
                "error: Multiple Initializers found move other initializers into a extension to disambiguate"
            )
            return .skipChildren

        } else if initializers.count == 1 {
            // explicit initializer found
            arguments = initializers[0].arguments
        } else if initializers.isEmpty, storedProperties.isEmpty {
            // we can use the implicit initializer
            arguments = []
        } else if initializers.isEmpty, !storedProperties.isEmpty {
            // we can use the default memberwise initializer
            arguments = storedProperties
        } else {
            print("error: No Initializer found for \(currentTypeName)")
            return .skipChildren
        }

        self.dependencyGraph.imports.formUnion(imports)

        self.dependencyGraph.provides.append(
            ProvidedDependency(
                location: node.startLocation(context: context),
                type: TypeDescriptor(name: currentTypeName),
                kind: .injectable,
                arguments: arguments
            )
        )

        dependencyGraph.uses.append(
            Injection(
                range: node.sourceRange(context: context),
                arguments: arguments
            )
        )

        return .skipChildren
    }

    override func visitPost(_ node: StructDeclSyntax) {
        namespace.removeLast()
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        namespace.append(node.identifier.withoutTrivia().description)
        return .visitChildren
    }

    override func visitPost(_ node: EnumDeclSyntax) {
        namespace.removeLast()
    }

}

extension TypeInheritanceClauseSyntax {

    var hasInjectableConformance: Bool {
        return inheritedTypeCollection.contains {
            let typeName = $0.typeName.withoutTrivia().description

            return [
                "Injectable", "SwiftDagger.Injectable",
            ].contains(typeName)
        }
    }

}
