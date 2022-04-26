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
