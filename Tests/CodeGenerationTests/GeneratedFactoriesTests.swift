import CodeGeneration
import CustomDump
import XCTest

@testable import DependencyAnalyzer
@testable import SourceModel

class DiagnosticsCollector: Diagnostics {
    var diagnostics: [Diagnostic] = []
    var hasErrors: Bool = false

    func record(_ diagnostic: Diagnostic) {
        diagnostics.append(diagnostic)
    }
}

class GeneratedFactoriesTests: XCTestCase {

    func testFactories() throws {

        let file = try SourceFile.parse(
            module: "Mock",
            fileName: "MockFile",
            source: """
                import TestModule

                struct ExplicitelyInitialized: Injectable {
                    init(
                        @Inject a: I,
                        @Assisted b: Int,
                        bla: Int = 1
                    ) {}


                    class Nested: Injectable {
                        init() {}
                    }
                }

                struct ImplicitInitializer: Injectable {
                    @Inject var a: I
                    @Assisted var b: Int
                    var bla: Int = 1
                }

                extension ImplicitInitializer {
                    struct Nested: Injectable {
                        @Inject var a: I
                        @Assisted var b: Int
                        var bla: Int = 1
                    }
                }
                """
        )

        let diagnostics = DiagnosticsCollector()

        let graph = try DependencyAnalysis.extractGraph(
            file: file,
            diagnostics: diagnostics
        )

        let text = CodeGen.generateSources(fileGraph: graph)

        XCTAssertNoDifference(
            text,
            """
            // Automatically generated DO NOT MODIFY

            import DependencyInjection
            import TestModule

            extension Mock_Module {
              func register_MockFile(_ registry: DependencyRegistry) {
                registry.register(Mock.ExplicitelyInitialized.self) { resolver in
                    Mock.ExplicitelyInitialized.newInstance(resolver: resolver)
                }
                registry.register(Mock.ExplicitelyInitialized.Nested.self) { resolver in
                    Mock.ExplicitelyInitialized.Nested.newInstance(resolver: resolver)
                }
                registry.register(Mock.ImplicitInitializer.self) { resolver in
                    Mock.ImplicitInitializer.newInstance(resolver: resolver)
                }
                registry.register(Mock.ImplicitInitializer.Nested.self) { resolver in
                    Mock.ImplicitInitializer.Nested.newInstance(resolver: resolver)
                }
              }
            }
            extension Mock.ExplicitelyInitialized {
              public static func newInstance(
                resolver: DependencyResolver = DependencyInjection.resolver,
                b: Int
              ) {
                Mock.ExplicitelyInitialized(
                  a: resolver.resolve(),
                  b: b
                )
              }
            }
            extension Mock.ExplicitelyInitialized.Nested {
              public static func newInstance(
                resolver: DependencyResolver = DependencyInjection.resolver
              ) {
                Mock.ExplicitelyInitialized.Nested()
              }
            }
            extension Mock.ImplicitInitializer {
              public static func newInstance(
                resolver: DependencyResolver = DependencyInjection.resolver,
                b: Int
              ) {
                Mock.ImplicitInitializer(
                  a: resolver.resolve(),
                  b: b
                )
              }
            }
            extension Mock.ImplicitInitializer.Nested {
              public static func newInstance(
                resolver: DependencyResolver = DependencyInjection.resolver,
                b: Int
              ) {
                Mock.ImplicitInitializer.Nested(
                  a: resolver.resolve(),
                  b: b
                )
              }
            }


            """
        )
    }

}
