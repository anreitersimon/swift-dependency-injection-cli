import DependencyModel
import Foundation
import SourceModel
import StoreKit

extension String {

    /// Returns a form of the string that is a valid bundle identifier
    public func swiftIdentifier() -> String {
        return self.filter { $0.isNumber || $0.isLetter }
    }
}

// TODO: Dont duplicate
extension Function.Argument {

    public var isInjected: Bool {
        !Constants.injectAnnotations.intersection(attributes).isEmpty
    }

    public var isAssisted: Bool {
        !Constants.assistedAnnotations.intersection(attributes).isEmpty
    }
}

extension Initializer {
    public var isAssisted: Bool {
        return arguments.contains(where: \.isAssisted)
    }
}

public enum CodeGen {

    static let header = "// Automatically generated DO NOT MODIFY"

    public static func generateSources(
        moduleGraph graph: ModuleDependencyGraph
    ) -> String {

        let writer = FileWriter()

        writer.writeMultiline(
            """
            \(header)

            import DependencyInjection

            """
        )

        writer.scope("public enum \(graph.module)_Module: DependencyInjection.DependencyModule") {
            $0.scope("public static func register(in registry: DependencyRegistry)") {
                for file in graph.files {
                    $0.writeLine("register_\(file.fileName.swiftIdentifier())(in: registry)")
                }
            }

        }

        return writer.builder
    }

    public static func generateSources(
        fileGraph graph: FileDependencyGraph
    ) -> String {

        let writer = FileWriter()

        writer.writeLine(header)
        writer.endLine()

        for imp in graph.imports {
            writer.writeLine(imp.description)
        }

        writer.endLine()

        writer.scope("extension \(graph.module)_Module") {
            $0.scope(
                "static func register_\(graph.fileName.swiftIdentifier())(in registry: DependencyRegistry)"
            ) {
                for provided in graph.provides
                where !provided.initializer.arguments.contains(where: \.isAssisted) {
                    $0.writeLine("\(provided.fullName).register(in: registry)")
                }
            }
        }

        for provided in graph.provides {
            writer.scope("extension \(provided.fullName)") {
                generateRegistration(in: $0, injectable: provided)
                generateTypeFactory(in: $0, injectable: provided)
            }
        }

        writer.endLine()

        return writer.builder
    }

    private static func generateRegistration(
        in writer: FileWriter,
        injectable: ProvidedType
    ) {
        writer.scope("fileprivate static func register(in registry: DependencyRegistry)") {
            generateRequirementsVariable(in: $0, injectable: injectable)

            switch injectable.kind {
            case .factory where injectable.initializer.isAssisted:
                $0.writeMultiline(
                    """
                    registry.registerAssistedFactory(
                        ofType: \(injectable.fullName).self,
                        requirements: requirements
                    )
                    """
                )
            case .factory, .singleton, .weakSingleton:
                let methodName: String
                
                switch injectable.kind {
                case .factory:
                    methodName = "registerFactory"
                case .singleton:
                    methodName = "registerSingleton"
                case .weakSingleton:
                    methodName = "registerWeakSingleton"
                }
                
                $0.writeMultiline(
                    """
                    registry.\(methodName)(
                        ofType: \(injectable.fullName).self,
                        requirements: requirements
                    ) { resolver in
                        \(injectable.fullName).newInstance(resolver: resolver)
                    }
                    """
                )
            }

        }
    }

    private static func generateTypeFactory(
        in writer: FileWriter,
        injectable: ProvidedType
    ) {
        let allArguments = injectable.initializer.arguments
            .filter { $0.isAssisted || $0.isInjected }
        let assisted = allArguments.filter(\.isAssisted)

        writer.writeLine("public static func newInstance(")
        writer.indent {
            $0.write("resolver: DependencyResolver = Dependencies.sharedResolver")

            for argument in assisted {
                $0.write(",")
                $0.endLine()
                $0.write(argument.description)
            }
        }
        writer.endLine()
        writer.scope(") -> \(injectable.fullName)") {
            $0.write("\(injectable.fullName)(")
            $0.indent {

                var isFirst = true

                for argument in allArguments where argument.isInjected || argument.isAssisted {

                    if !isFirst {
                        $0.write(",")
                    }
                    $0.endLine()

                    if let argName = argument.callSiteName {
                        $0.write(argName)
                        $0.write(": ")
                    }

                    if argument.isInjected {
                        $0.write("resolver.resolve()")
                    } else if argument.isAssisted {
                        let internalName = argument.secondName ?? argument.firstName

                        assert(internalName != nil, "argument must at least have internal name")

                        $0.write(internalName!)
                    }
                    isFirst = false
                }
            }

            if !allArguments.isEmpty {
                $0.endLine()
            }

            $0.write(")")
        }

    }

    private static func generateRequirementsVariable(
        in writer: FileWriter,
        injectable: ProvidedType
    ) {
        let injected = injectable.initializer.arguments.filter(\.isInjected)

        writer.write("let requirements: [String: Any.Type] = [")

        guard !injected.isEmpty else {
            writer.write(":]")
            writer.endLine()
            writer.endLine()
            return
        }
        writer.endLine()

        writer.indent {
            for field in injected {
                if let metaType = field.type?.asMetatype() {
                    $0.writeLine("\"\(field.firstName ?? field.secondName ?? "-")\": \(metaType),")
                }
            }
        }
        writer.writeLine("]")
        writer.endLine()
    }
}
