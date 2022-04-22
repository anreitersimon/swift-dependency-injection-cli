import Foundation

public class FileWriter {
    var singleIndent = "  "
    var currentIndent = ""

    var builder = ""
    var isAtBeginning = true

    public init() {

    }

    func indent(performIndented: (FileWriter) -> Void) {
        let originalIndent = currentIndent
        currentIndent.append(singleIndent)

        performIndented(self)

        currentIndent = originalIndent
    }

    func scope(performIndented: (FileWriter) -> Void) {
        self.write(" {")
        self.endLine()
        self.indent(performIndented: performIndented)
        if !isAtBeginning {
            self.endLine()
        }
        self.writeLine("}")
    }

    func endLine() {
        self.builder.append("\n")
        self.isAtBeginning = true
    }

    @discardableResult
    func writeLine(_ str: String) -> FileWriter {
        self.write(str)
        self.endLine()

        return self
    }

    @discardableResult
    func write(_ str: String) -> FileWriter {
        if isAtBeginning {
            builder.append(currentIndent)
        }

        builder.append(str)
        self.isAtBeginning = false

        return self
    }

    public func write(_ writable: Writable, to url: URL) throws {
        writable.write(to: self)

        try self.builder.write(to: url, atomically: true, encoding: .utf8)
    }
}
