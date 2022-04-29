import DependencyModel
import Foundation
import SourceModel

protocol TypeInheritance {
    var inheritedTypes: [TypeSignature] { get }
    var sourceRange: SourceRange? { get }
}

extension Extension: TypeInheritance {}
extension TypeDeclaration: TypeInheritance {}

extension TypeInheritance {

    var conformsToInjectable: Bool {
        !injectableConformances.isEmpty
    }

    var injectableConformances: [InjectableProtocol] {
        inheritedTypes.compactMap(InjectableProtocol.from(type:))
    }

}

extension TypeDeclaration {

    func initializersWithInjectableArguments() -> [Initializer] {
        self.allAvailableInitializers.filter {
            $0.arguments.contains { $0.isAssisted || $0.isInjected }
        }
    }

    func findPrimaryInitializer(
        diagnostics: Diagnostics
    ) -> SourceModel.Initializer? {

        guard initializers.count <= 1 else {
            diagnostics.error(
                "Too many Initializers defined for Injectable type \(name)\nMove other Initializers to a extension to disambiguate"
            )

            return nil
        }

        let initializer: SourceModel.Initializer

        if initializers.count == 1 {
            initializer = initializers[0]

        } else {
            guard let memberwiseInitializer = implicitMemberwiseInitializer else {
                diagnostics.error(
                    "No Initializer defined for Injectable type \(name)"
                )

                return nil
            }
            initializer = memberwiseInitializer
        }

        guard initializer.isInjectable(diagnostics: diagnostics) else {
            return nil
        }

        return initializer
    }
}

extension Function.Argument {

    public var isInjected: Bool {
        !Constants.injectAnnotations.intersection(attributes).isEmpty
    }

    public var isAssisted: Bool {
        !Constants.assistedAnnotations.intersection(attributes).isEmpty
    }

    func isInjectable(diagnostics: Diagnostics) -> Bool {
        var isValid = true
        let name = firstName ?? secondName ?? ""

        let injectableAnnotations = Constants.injectAnnotations.intersection(attributes)

        let assistedAnnotations = Constants.assistedAnnotations.intersection(attributes)

        if injectableAnnotations.count > 1 {
            diagnostics.warn("Too many Inject Annotation for \(name)")
        }
        if assistedAnnotations.count > 1 {
            diagnostics.warn(
                "Too many Assisted Annotation for \(name)",
                at: self.sourceRange?.start
            )
        }

        if !injectableAnnotations.isEmpty && !assistedAnnotations.isEmpty {
            isValid = false

            diagnostics.error(
                "Cannot combine Inject and Assisted",
                at: self.sourceRange?.start
            )
        }

        if injectableAnnotations.isEmpty
            && assistedAnnotations.isEmpty
            && defaultValue == nil
        {
            diagnostics.error(
                "argument \(name) must either be annotated with Inject or Assisted or provide a defaultValue",
                at: self.sourceRange?.start
            )
        }

        return isValid
    }

}

extension SourceModel.Initializer {
    func isInjectable(diagnostics: Diagnostics) -> Bool {
        var isValid = true

        for arg in self.arguments {
            isValid = isValid && arg.isInjectable(diagnostics: diagnostics)
        }

        return isValid
    }
}

public enum DependencyAnalysisError: Error {
    case error
}

public enum DependencyAnalysis {

    public static func extractGraph(
        file: SourceFile,
        diagnostics: Diagnostics
    ) throws -> FileDependencyGraph {

        // TODO: Handle nested types
        var graph = FileDependencyGraph(
            fileName: file.fileName,
            module: file.module,
            imports: file.imports
        )

        for ext in file.extensions where ext.conformsToInjectable {
            diagnostics.error(
                "Injectable conformance must be declared in the type-declaration",
                at: ext.sourceRange?.start
            )
        }

        typeLoop: for type in file.recursiveTypes {
            let conformances = type.injectableConformances
            let conformanceKind: InjectableProtocol
            let initializers = type.initializersWithInjectableArguments()

            switch conformances.count {
            case 0:  // does not support injection
                if !initializers.isEmpty {
                    for initializer in initializers {
                        diagnostics.error(
                            "Type must declare Injectable support by inheriting from one of \(InjectableProtocol.protocolNames))",
                            at: initializer.sourceRange?.start
                        )
                    }
                }

                continue typeLoop
            case 1:
                conformanceKind = conformances[0]
            default:
                diagnostics.error(
                    "Only one conformance allowed \(conformances.map(\.rawValue).joined(separator: ", "))",
                    at: type.sourceRange?.start
                )
                continue typeLoop
            }

            if !type.generics.isEmpty {
                diagnostics.error("Generic Types are not supported", at: type.sourceRange?.start)
            }

            guard
                let initializer = type.findPrimaryInitializer(diagnostics: diagnostics)
            else {
                continue typeLoop
            }
            let assisted = initializer.arguments.filter(\.isAssisted)
            if !assisted.isEmpty, conformanceKind != .factory {
                for assistedArgument in assisted {
                    diagnostics.error(
                        "@Assisted not supported with \(conformanceKind.rawValue)\nOnly is supported \(InjectableProtocol.factory.rawValue)",
                        at: assistedArgument.sourceRange?.start
                    )
                }

                continue typeLoop
            }

            graph.register(
                type,
                kind: conformanceKind,
                initializer: initializer
            )
        }

        return graph

    }

}
