import DependencyAnalyzer
import SwiftSyntax
import SwiftSyntaxParser
import XCTest

@testable import DependencyAnalyzer

class SourceFileScannerTests: XCTestCase {

    func testExample() throws {

        let context = Context.mock(
            """
            @_exported import Mock
            
            class Class: Injectable {
                let a: Int
                static let b: (Int, String)
                                
                init(@Injected a: Int = 1) {}
            }
            
            extension A {
                            
                init(@Injected a: Int = 1) {}
            
            }

            struct Struct: Injectable {}

            enum Struct: Injectable {}

            """
        )

        let scanner = SourceFileScanner(context: context)
        scanner.walk(context.syntax)

        let graph = scanner.dependencyGraph

        dump(scanner.sourceFile)

        XCTAssert(graph.provides.count == 1)
    }
}

extension Context {
    static func mock(_ string: String) -> Context {
        Context.init(
            moduleName: "Mock",
            syntax: try! SyntaxParser.parse(source: string),
            converter: SourceLocationConverter(file: "File.swift", source: string)
        )
    }
}
