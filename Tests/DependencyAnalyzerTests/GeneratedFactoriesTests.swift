import CustomDump
import SourceModel
import XCTest

@testable import DependencyAnalyzer

class AnalizerTests: XCTestCase {

    class DiagnosticsCollector: Diagnostics {
        var diagnostics: [Diagnostic] = []
        var hasErrors: Bool = false

        func record(_ diagnostic: Diagnostic) {
            diagnostics.append(diagnostic)
        }

    }

    func testFactories() throws {
        let diagnostics = DiagnosticsCollector()

        let file = try SourceFile.parse(
            module: "Mock",
            fileName: "MockFile",
            source: """
                import DependencyInjection
                import TestModule

                struct ExplicitelyInitialized: Injectable {
                    init(
                        @Inject a: I,
                        @Assisted b: Int,
                        bla: Int = 1
                    ) {}
                }

                struct ImplicitInitializer: Injectable {
                    @Inject var a: I
                    @Assisted var b: Int
                    var bla: Int = 1
                }
                """
        )

//        guard let e = DependencyAnalysis.analyze(
//            file: file,
//            diagnostics: diagnostics
//        ) else {
//            XCTFail()
//            return
//        }
//
//        for (type, initializer) in e {
//            print(initializer)
//        }
    }

}
