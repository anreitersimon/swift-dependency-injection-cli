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

    func scope(_ prefix: String? = nil, performIndented: (FileWriter) -> Void) {
        if let prefix = prefix {
            self.write(prefix)
        }
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
    
    @discardableResult
    func writeMultiline(_ str: String) -> FileWriter {
        let lines = str.split(whereSeparator: \.isNewline)
        
        for line in lines {
            writeLine(String(line))
        }
        return self
    }

    public func write(_ writable: Writable, to url: URL) throws {
        writable.write(to: self)

        try self.builder.write(to: url, atomically: true, encoding: .utf8)
    }
}
