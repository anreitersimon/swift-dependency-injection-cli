import CustomDump
import XCTest

@testable import SourceModel

class SourceFileScannerTests: XCTestCase {

    func testVariableDeclarations() throws {

        let parsed = try SourceFile.parse(
            module: "Mock",
            source: """
                let variable: Int
                let variable_Optional: Int?
                let variable_ImplicitlyUnwrappedOptional: Int!
                let variable_ImplicitlyUnwrappedOptional: Optional<Int>

                let tuple: (Int, String)
                let tuple_Named: (a: Int, b: Int)
                let tupe_Named_Optional: (a: Int, b: Int)?

                public static let field: Int
                """
        )

        XCTAssertNoDifference(
            Variable(
                name: "variable",
                type: .simple("Int"),
                attributes: [],
                modifiers: [],
                isStored: true
            ),
            parsed.variables[0]
        )

        XCTAssertNoDifference(
            Variable(
                name: "variable_Optional",
                type: .optional(.simple("Int")),
                attributes: [],
                modifiers: [],
                isStored: true
            ),
            parsed.variables[1]
        )

        XCTAssertNoDifference(
            Variable(
                name: "variable_ImplicitlyUnwrappedOptional",
                type: .implicitlyUnwrappedOptional(.simple("Int")),
                attributes: [],
                modifiers: [],
                isStored: true
            ),
            parsed.variables[2]
        )
    }
}
