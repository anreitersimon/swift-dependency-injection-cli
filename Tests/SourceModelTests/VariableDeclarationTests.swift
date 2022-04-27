import CustomDump
import SwiftUI
import XCTest

@testable import SourceModel

class VariableDeclarationTests: XCTestCase {

    func expectVariable(
        _ input: String,
        _ expected: Variable,
        file: StaticString = #filePath
    ) throws {
        let parsed = try SourceFile.parse(
            module: "Mock",
            source: input
        )

        XCTAssertEqual(parsed.variables.count, 1, file: file)
        XCTAssertNoDifference(
            parsed.variables.first,
            expected,
            file: file
        )
    }

    func testVariableDeclarations() throws {

        try expectVariable(
            "let variable: Int",
            Variable(
                name: "variable",
                type: .simple(name: "Int")
            )
        )

        try expectVariable(
            "let variable_InferredType = 1",
            Variable(
                name: "variable_InferredType",
                type: nil,
                defaultValue: "1"
            )
        )

        try expectVariable(
            "let variable_Optional: Int?",
            Variable(
                name: "variable_Optional",
                type: .optional(.simple(name: "Int"))
            )
        )

        try expectVariable(
            "let variable_ImplicitlyUnwrappedOptional: Int!",
            Variable(
                name: "variable_ImplicitlyUnwrappedOptional",
                type: .implicitlyUnwrappedOptional(.simple(name: "Int"))
            )
        )

        try expectVariable(
            "let variable_ExplicitOptional: Optional<Int>",
            Variable(
                name: "variable_ExplicitOptional",
                type: .simple(
                    name: "Optional",
                    genericArguments: [.simple(name: "Int")]
                )
            )
        )

    }

    func testVariableAttributes() throws {

        try expectVariable(
            "@Inject var variable: Int",
            Variable(
                name: "variable",
                type: .simple(name: "Int"),
                attributes: ["@Inject"]
            )
        )

    }

}
