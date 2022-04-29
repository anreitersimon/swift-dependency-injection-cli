import Foundation
import SourceModel

public enum Constants {
    public static let runtimeLibraryName = "DependencyInjection"

    public static let assistedAnnotations: Set<String> = [
        "@Assisted",
        "@\(runtimeLibraryName).Assisted",
        "@Assisted()",
        "@\(runtimeLibraryName).Assisted()",
    ]

    public static let injectAnnotations: Set<String> = [
        "@Inject",
        "@\(runtimeLibraryName).Inject",
        "@Inject()",
        "@\(runtimeLibraryName).Inject()",
    ]

    public static let allAnnotations =
        assistedAnnotations
        .union(injectAnnotations)
}

public enum InjectableProtocol: String, CaseIterable, Codable {
    case factory = "Injectable"
    case singleton = "Singleton"
    case weakSingleton = "WeakSingleton"

    public var variants: Set<String> {
        return [rawValue, "\(Constants.runtimeLibraryName).\(self.rawValue)"]
    }

    public static var protocolNames: String { allCases.map(\.rawValue).joined(separator: ", ") }

    private static let mappings: [String: InjectableProtocol] = Dictionary(
        uniqueKeysWithValues: allCases.flatMap { value in
            value.variants.map { variant in (variant, value) }
        }
    )

    public static func from(type: TypeSignature) -> InjectableProtocol? {
        guard case .simple(let name, _) = type else {
            return nil
        }

        return mappings[name]
    }
}
