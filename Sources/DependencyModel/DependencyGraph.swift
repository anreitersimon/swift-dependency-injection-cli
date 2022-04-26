import Foundation
import SourceModel

public struct DependencyGraph: Codable {
    public var imports: Set<String> = []
    public var provides: [ProvidedDependency] = []
    public var uses: [Injection] = []

    public init() {}

    public mutating func merge(_ other: DependencyGraph) {
        self.imports.formUnion(other.imports)
        self.provides.append(contentsOf: other.provides)
        self.uses.append(contentsOf: other.uses)
    }

    public func write(to url: URL) throws {
        let encoder = JSONEncoder()
        if #available(macOS 10.13, *) {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        } else {
            encoder.outputFormatting = [.prettyPrinted]
        }

        try encoder.encode(self).write(to: url, options: .atomic)
    }
}

public struct Initializer: Codable {
    public let arguments: [Parameter]
    public let range: SourceRange

    public init(arguments: [Parameter], range: SourceRange) {
        self.arguments = arguments
        self.range = range
    }

}

public enum Constants {
    public static let runtimeLibraryName = "DependencyInjection"

    public static let assistedAnnotations: Set<String> = [
        "Assisted",
        "\(runtimeLibraryName).Assisted",
    ]

    public static let injectAnnotations: Set<String> = [
        "Inject",
        "\(runtimeLibraryName).Inject",
    ]

    public static let allAnnotations =
        assistedAnnotations
        .union(injectAnnotations)
}

public struct Parameter: Codable {
    public let type: TypeDescriptor
    public let firstName: String
    public let secondName: String?
    public let attributes: [String]
    public let range: SourceRange

    public init(
        type: TypeDescriptor,
        firstName: String,
        secondName: String?,
        attributes: [String],
        range: SourceRange
    ) {
        self.type = type
        self.firstName = firstName
        self.secondName = secondName
        self.attributes = attributes
        self.range = range
    }

    public var isCustomAnnotation: Bool {
        !Constants.allAnnotations.isDisjoint(with: attributes)
    }

    public var isAssisted: Bool {
        !Constants.assistedAnnotations.isDisjoint(with: attributes)
    }

    public var isInjected: Bool {
        !Constants.injectAnnotations.isDisjoint(with: attributes)
    }
}

public struct Injection: Codable {
    public let range: SourceRange
    public let arguments: [Parameter]

    public init(range: SourceRange, arguments: [Parameter]) {
        self.range = range
        self.arguments = arguments
    }
}

public struct TypeDescriptor: Codable {
    public let name: String

    public init(name: String) {
        self.name = name
    }
}

public struct ProvidedDependency: Codable {
    public let location: SourceLocation
    public let type: TypeDescriptor
    public let arguments: [Parameter]
    public let kind: Kind

    public init(
        location: SourceLocation,
        type: TypeDescriptor,
        kind: ProvidedDependency.Kind,
        arguments: [Parameter]
    ) {
        self.location = location
        self.type = type
        self.kind = kind
        self.arguments = arguments
    }

    public enum Kind: Codable {
        case provides
        case bind
        case injectable
    }
}
