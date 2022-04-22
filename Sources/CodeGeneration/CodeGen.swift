import DependencyModel
import Foundation

public enum CodeGen {

    @TextBuilder
    public static func generatedFactories(
        graph: DependencyGraph
    ) -> Writable {

        for importStmt in graph.imports {
            importStmt
        }

        for provided in graph.provides {

            let defaultArgs = [
                Function.Argument(
                    firstName: "resolver",
                    secondName: nil,
                    type: "DependencyResolver",
                    defaultValue: "DependencyInjection.resolver"
                )
            ]
            let assistedProperties = provided.arguments
                .filter { $0.isAssisted }
                .map { $0.toFunctionArgument() }

            Extension(name: provided.type.name) {
                Function(
                    name: "create",
                    arguments: defaultArgs + assistedProperties,
                    returnType: provided.type.name,
                    modifiers: ["public", "static"],
                    trailingModifiers: []
                ) {

                    let callArgs = provided.arguments.map { param -> String in

                        let arg: String

                        if param.isAssisted {
                            arg = param.secondName ?? param.firstName
                        } else {
                            arg = "resolver.resolve(\(param.type.name).self)"
                        }
                        return
                            param
                            .toFunctionArgument()
                            .callWith(argument: arg)
                    }

                    "return \(provided.type.name)(\(callArgs.joined(separator: ", ")))"
                }
            }
        }

        ""
    }

    ///
    /// protocol Module {
    ///    func register(in registry: DependencyRegistry)
    ///    func validate(resolver: DependencyResolver) throws
    /// }

    @TextBuilder
    public static func generateModule(
        moduleName: String,
        graph: DependencyGraph
    ) -> Writable {

        for importStmt in graph.imports.sorted() {
            importStmt
        }

        TypeDeclaration(
            kind: "struct",
            name: "\(moduleName)Module: Module",
            accessLevel: "public"
        ) {
            "public init() {}"

            Function(
                name: "register",
                arguments: [
                    Function.Argument(
                        firstName: "in",
                        secondName: "registry",
                        type: "DependencyRegistry"
                    )
                ],
                returnType: nil,
                modifiers: ["public"],
                trailingModifiers: []
            ) {

                for provided in graph.provides
                where provided.arguments.allSatisfy({ !$0.isAssisted }) {
                    "registry.register(as: \(provided.type.name).self) { \(provided.type.name).create(resolver: $0) }"
                }
            }

            Function(
                name: "validate",
                arguments: [
                    Function.Argument(
                        firstName: "resolver",
                        secondName: nil,
                        type: "DependencyResolver"
                    )
                ],
                returnType: nil,
                modifiers: ["public"],
                trailingModifiers: ["throws"]
            ) {

                let usedTypes = Dictionary(
                    grouping: graph.uses.flatMap { $0.arguments },
                    by: { $0.type.name }
                )

                for (key, _) in usedTypes {
                    "print(\"resolving \(key)\")"
                    "let _ = try resolver._tryResolve(\(key).self)"
                }

            }
        }
    }
}

extension DependencyModel.Parameter {
    func toFunctionArgument() -> Function.Argument {
        Function.Argument(
            firstName: firstName,
            secondName: secondName,
            type: type.name
        )
    }
}
