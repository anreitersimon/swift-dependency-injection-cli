import Foundation

public protocol Writable {
    func write(to writer: FileWriter)
}

extension Writable {
    public func writeToFile(_ url: URL) throws {
        let writer = FileWriter()
        try writer.write(self, to: url)
    }
}

struct CompositeWritable: Writable {
    let elements: [Writable]
    let endLines: Bool

    func write(to writer: FileWriter) {
        for element in elements {
            element.write(to: writer)
            if endLines {
                writer.endLine()
            }
        }
    }
}

struct Line: Writable {
    let text: String

    func write(to writer: FileWriter) {
        writer.writeLine(text)
    }
}

public func Class(
    _ name: String,
    accessLevel: String? = nil,
    @TextBuilder body: @escaping () -> Writable
) -> TypeDeclaration {
    TypeDeclaration(kind: "class", name: name, accessLevel: accessLevel, body: body)
}


public struct Variable: Writable {
    public let mutable: Bool
    public let name: String
    public let type: String

    public init(
        mutable: Bool = false,
        name: String,
        type: String
    ) {
        self.mutable = mutable
        self.name = name
        self.type = type
    }

    public func write(to writer: FileWriter) {
        writer.write("\(mutable ? "var": "let") \(name): \(type)")
    }
}
