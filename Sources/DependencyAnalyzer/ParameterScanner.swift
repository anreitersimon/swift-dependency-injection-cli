import DependencyModel
import Foundation
@_implementationOnly import SwiftSyntax

extension FunctionParameterSyntax {

    fileprivate func extractArgument(
        context: Context
    ) -> Parameter? {
        guard
            let typeName = type?.withoutTrivia().description,
            let name = firstName?.withoutTrivia().description
        else {
            return nil
        }

        let attributes =
            attributes?
            .compactMap { $0.as(CustomAttributeSyntax.self) }
            .map { $0.attributeName.withoutTrivia().description }

        return Parameter(
            type: TypeDescriptor(name: typeName),
            firstName: name,
            secondName: secondName?.withoutTrivia().description,
            attributes: attributes ?? [],
            range: self.sourceRange(context: context)
        )

    }

}

extension FunctionParameterListSyntax {

    fileprivate func extractArguments(context: Context) -> [Parameter] {
        return self.compactMap { parameter in
            parameter.extractArgument(context: context)
        }
    }

}

extension FunctionDeclSyntax {

    func extractArguments(
        context: Context
    ) -> [Parameter] {
        self.signature.input.parameterList.extractArguments(context: context)
    }

}

extension InitializerDeclSyntax {
    func extractArguments(context: Context) -> [Parameter] {
        return parameters.parameterList.extractArguments(context: context)
    }
}
