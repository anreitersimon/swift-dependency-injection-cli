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

public enum CodeGen {

    public static func generateSources(
        fileGraph graph: FileDependencyGraph
    ) -> String {

        let writer = FileWriter()

        writer.writeLine("// Automatically generated DO NOT MODIFY")
        writer.endLine()

        for imp in graph.imports {
            writer.writeLine(imp.description)
        }

        writer.endLine()

        writer.scope("extension \(graph.module)_Module") {
            $0.scope(
                "func register_\(graph.fileName.swiftIdentifier())(_ registry: DependencyRegistry)"
            ) {
                for provided in graph.provides {
                    $0.writeMultiline(
                        """
                        registry.register(\(provided.fullName).self) { resolver in
                            \(provided.fullName).newInstance(resolver: resolver)
                        }
                        """
                    )
                }
            }
        }

        for provided in graph.provides {
            writer.scope("extension \(provided.fullName)") {
                generateTypeFactory(in: $0, injectable: provided)

            }
        }

        writer.endLine()

        return writer.builder
    }

    private static func generateTypeFactory(
        in writer: FileWriter,
        injectable: InjectableType
    ) {
        let allArguments = injectable.initializer.arguments
            .filter { $0.isAssisted || $0.isInjected }
        let assisted = allArguments.filter(\.isAssisted)

        writer.writeLine("public static func newInstance(")
        writer.indent {
            $0.write("resolver: DependencyResolver = DependencyInjection.resolver")

            for argument in assisted {
                $0.write(",")
                $0.endLine()
                $0.write(argument.description)
            }
        }
        writer.endLine()
        writer.scope(")") {
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
}
