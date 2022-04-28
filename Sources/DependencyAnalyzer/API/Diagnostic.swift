import SourceModel

public struct Diagnostic: CustomStringConvertible {
    enum Level: String {
        case warning
        case error
        case note
        case remark
    }

    let message: String
    let level: Level
    let location: SourceLocation?

    public var description: String {
        let prefix = location.map { "\($0.description): " } ?? ""

        return "\(prefix)\(level.rawValue): \(message)"
    }

}

public protocol Diagnostics {
    func record(_ diagnostic: Diagnostic)
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
