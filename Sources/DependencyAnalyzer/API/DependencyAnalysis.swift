import DependencyModel
import Foundation
import SourceModel

extension TypeDeclaration {
    var conformsToInjectable: Bool {
        inheritedTypes.contains {
            switch $0 {
            case .simple(let name, _):
                return Constants.injectableProtocols.contains(name)
            default: return false
            }
        }
    }
}

extension Extension {
    var conformsToInjectable: Bool {
        inheritedTypes.contains {
            switch $0 {
            case .simple(let name, _):
                return Constants.injectableProtocols.contains(name)
            default: return false
            }
        }
    }
}

extension TypeDeclaration {

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
            diagnostics.warn("Too many Assisted Annotation for \(name)")
        }

        if !injectableAnnotations.isEmpty && !assistedAnnotations.isEmpty {
            isValid = false

            diagnostics.error("Cannot combine Inject and Assisted")
        }

        if injectableAnnotations.isEmpty
            && assistedAnnotations.isEmpty
            && defaultValue == nil
        {
            diagnostics.error(
                "argument \(name) must either be annotated with Inject or Assisted or provide a defaultValue"
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

        var isFileValid = true
        var graph = FileDependencyGraph(
            fileName: file.fileName,
            module: file.module,
            imports: file.imports
        )

        for ext in file.extensions where ext.conformsToInjectable {
            diagnostics.error(
                "Injectable conformance must be declared in the type-declaration"
            )
        }

        for type in file.recursiveTypes where type.conformsToInjectable {

            if !type.generics.isEmpty {
                diagnostics.error("Generic Types are not supported")
            }

            guard
                let initializer = type.findPrimaryInitializer(diagnostics: diagnostics)
            else {
                isFileValid = false
                continue
            }
            graph.register(type, initializer: initializer)
        }

        guard isFileValid else {
            throw DependencyAnalysisError.error
        }

        return graph

    }

}
