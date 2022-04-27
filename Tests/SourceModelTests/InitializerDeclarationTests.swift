import CustomDump
import SwiftUI
import XCTest

@testable import SourceModel

class InitializerDeclarationTests: XCTestCase {

    func expectInitializer(
        _ input: String,
        _ expected: Initializer,
        file: StaticString = #filePath
    ) throws {
        let parsed = try SourceFile.parse(
            module: "Mock",
            source: input
        )

        XCTAssertEqual(parsed.initializers.count, 1, file: file)
        XCTAssertNoDifference(
            parsed.initializers.first,
            expected,
            file: file
        )
    }

    func testVariableDeclarations() throws {

        try expectInitializer(
            "init() {}",
            Initializer()
        )

        try expectInitializer(
            "init(a: Int, b: Int? = nil) {}",
            Initializer(arguments: [
                .init(
                    firstName: "a",
                    secondName: nil,
                    type: .simple(name: "Int")
                ),
                .init(
                    firstName: "b",
                    secondName: nil,
                    type: .optional(.simple(name: "Int")),
                    defaultValue: "nil"
                ),
            ])
        )
    }

}
