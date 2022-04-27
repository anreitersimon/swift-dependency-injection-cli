import CodeGeneration
import CustomDump
import SourceModel
import XCTest

class GeneratedFactoriesTests: XCTestCase {

    func testFactories() throws {

        let file = try SourceFile.parse(
            module: "Mock",
            fileName: "MockFile",
            source: """
                struct Bla {}
                """
        )

        XCTAssertNoDifference(
            CodeGen.generateFactories(source: file),
            """
            // Automatically generated DO NOT MODIFY


            extension Mock_Module {
              func register_MockFile(_ registry: DependencyRegistry) {
                // register all types in this file
              }
            }

            extension Mock.Bla {
              internal static func register(
            }

            """
        )
    }

}
