import SourceModel

public struct Diagnostic: CustomStringConvertible {
    public enum Level: String {
        case warning
        case error
        case note
        case remark
    }

    public let message: String
    public let level: Level
    public let location: SourceLocation?

    public var description: String {
        var prefix = location.map { "\($0.description): " } ?? ""
        if prefix.hasPrefix("file://") {
            prefix.removeFirst("file://".count)
        }

        return "\(prefix)\(level.rawValue): \(message)"
    }

}

public protocol Diagnostics {
    func record(_ diagnostic: Diagnostic)
    
    var hasErrors: Bool { get }
}

extension Diagnostics {
    func warn(_ message: String, at location: SourceLocation? = nil) {
        record(Diagnostic(message: message, level: .warning, location: location))
    }
    func error(_ message: String, at location: SourceLocation? = nil) {
        record(Diagnostic(message: message, level: .error, location: location))
    }
    func note(_ message: String, at location: SourceLocation? = nil) {
        record(Diagnostic(message: message, level: .note, location: location))
    }
}
