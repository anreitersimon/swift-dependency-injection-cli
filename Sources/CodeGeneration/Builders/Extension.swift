import Foundation

public struct Extension: Writable {

    let name: String
    let body: Writable

    public init(
        name: String,
        @TextBuilder body: () -> Writable
    ) {
        self.name = name
        self.body = body()
    }

    public func write(to writer: FileWriter) {
        writer.write("extension \(name)")
        writer.scope(performIndented: body.write(to:))
    }
}
