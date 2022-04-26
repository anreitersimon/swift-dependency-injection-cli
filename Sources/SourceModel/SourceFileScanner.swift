import Foundation
@_implementationOnly import SwiftSyntax

class SourceFileScanner: SyntaxVisitor {
    let context: Context

    /// stack of type declarations to keep track of the current scope
    var scopes: [DeclarationScope]

    var path: String { scopes.map(\.path).joined(separator: ".") }

    var sourceFile: SourceFile {
        get { scopes[0] as! SourceFile }
        set { scopes[0] = newValue }
    }

    var currentScope: DeclarationScope {
        get { scopes[scopes.count - 1] }
        set { scopes[scopes.count - 1] = newValue }
    }

    init(context: Context) {
        self.context = context
        self.scopes = [SourceFile(module: context.moduleName)]
    }

    override func visitPost(_ node: ImportDeclSyntax) {
        sourceFile.imports.append(
            .init(
                modifers: node.modifiers?.map { $0.trimmed } ?? [],
                attributes: node.attributes?.map { $0.trimmed } ?? [],
                kind: node.importKind.map {
                    TypeDeclaration.Kind(rawValue: $0.text)!
                },
                path: node.path.withoutTrivia().description
            )
        )
    }

    override func visit(_ node: CodeBlockSyntax) -> SyntaxVisitorContinueKind {
        print("Skipping CodeBlockSyntax")
        return .skipChildren
    }

    override func visit(
        _ node: InitializerDeclSyntax
    ) -> SyntaxVisitorContinueKind {

        var initializer = Initializer(
            modifiers: .fromModifiers(node.modifiers),
            trailingModifiers: []
        )

        for parameter in node.parameters.parameterList {
            initializer.arguments.append(
                Function.Argument(
                    firstName: parameter.firstName?.text,
                    secondName: parameter.secondName?.text,
                    type: parameter.type?.trimmed,
                    attributes: parameter.attributes?.map { $0.trimmed } ?? [],
                    defaultValue: parameter.defaultArgument?.value.trimmed
                )
            )
        }

        currentScope.initializers.append(initializer)

        return .skipChildren
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {

        let typeDecl = TypeDeclaration(
            module: context.moduleName,
            name: node.identifier.trimmed,
            kind: .class,
            modifiers: .fromModifiers(node.modifiers)
        )

        scopes.append(typeDecl)

        return .visitChildren
    }

    override func visitPost(_ node: ClassDeclSyntax) {
        let typeDecl = scopes.removeLast() as! TypeDeclaration
        currentScope.types.append(typeDecl)
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {

        let typeDecl = TypeDeclaration(
            module: context.moduleName,
            name: node.identifier.trimmed,
            kind: .struct,
            modifiers: .fromModifiers(node.modifiers)
        )

        scopes.append(typeDecl)

        return .visitChildren
    }

    override func visitPost(_ node: StructDeclSyntax) {
        let typeDecl = scopes.removeLast() as! TypeDeclaration
        currentScope.types.append(typeDecl)
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {

        let typeDecl = TypeDeclaration(
            module: context.moduleName,
            name: node.identifier.trimmed,
            kind: .struct,
            modifiers: .fromModifiers(node.modifiers)
        )

        scopes.append(typeDecl)

        return .visitChildren
    }

    override func visitPost(_ node: EnumDeclSyntax) {
        let typeDecl = scopes.removeLast() as! TypeDeclaration
        currentScope.types.append(typeDecl)
    }

    override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        let typeDecl = Extension(
            extendedType: node.extendedType.withoutTrivia().description
        )

        scopes.append(typeDecl)
        return .visitChildren
    }

    override func visitPost(_ node: ExtensionDeclSyntax) {
        let typeDecl = scopes.removeLast() as! Extension
        sourceFile.extensions.append(typeDecl)
    }

    override func visit(_ node: FunctionDeclSyntax) -> SyntaxVisitorContinueKind {
        .skipChildren
    }

    override func visit(
        _ node: VariableDeclSyntax
    ) -> SyntaxVisitorContinueKind {
        guard let binding = node.bindings.first else {
            return .skipChildren
        }
        let name = binding.pattern.withoutTrivia().description
        let isStored = binding.accessor == nil

        let variableType: Variable.VariableType?

        if let type = binding.typeAnnotation?.type {
            variableType = .fromTypeSyntax(type)
        } else {
            variableType = nil
        }

        currentScope.variables.append(
            Variable(
                name: name,
                type: variableType,
                attributes: [],
                modifiers: .fromModifiers(node.modifiers),
                isStored: isStored
            )
        )
        return .skipChildren
    }

}
