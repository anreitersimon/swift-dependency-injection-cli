import Foundation

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

public struct SourceLocation: Hashable, Codable, CustomDebugStringConvertible {
    /// The line in the file where this location resides. 1-based.
    public let line: Int

    /// The UTF-8 byte offset from the beginning of the line where this location
    /// resides. 1-based.
    public let column: Int

    /// The file in which this location resides.
    public let file: String

    public var debugDescription: String {
        // Print file name?
        return "\(line):\(column)"
    }

    public init(line: Int, column: Int, file: String) {
        self.line = line
        self.column = column
        self.file = file
    }
}

/// Represents a start and end location in a Swift file.
public struct SourceRange: Hashable, Codable, CustomDebugStringConvertible {

    /// The beginning location in the source range.
    public let start: SourceLocation

    /// The beginning location in the source range.
    public let end: SourceLocation

    public var debugDescription: String {
        return "(\(start.debugDescription),\(end.debugDescription))"
    }

    public init(start: SourceLocation, end: SourceLocation) {
        self.start = start
        self.end = end
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

    public var isAssisted: Bool {
        attributes.contains("Assisted") || attributes.contains("DependencyInjection.Assisted")
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
