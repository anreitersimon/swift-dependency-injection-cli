import XCTest
@testable import SourceModel
import CustomDump

class TypeInferenceTests: XCTestCase {

    func testInferOptionalLiteral() {
        let inputs: [TypeSignature] = [
            .simple(
                name: "Optional",
                genericArguments: [
                    .simple(name: "Int")
                ]
            ),
            .simple(
                name: "Swift.Optional",
                genericArguments: [
                    .simple(name: "Int")
                ]
            ),
        ]

        XCTAssertNoDifference(
            [
                .optional(.simple(name: "Int")),
                .optional(.simple(name: "Int")),
            ],
            inputs.map { $0.inferLiteralTypes() }
        )

    }

    func testInferDictionaryLiteral() {
        let inputs: [TypeSignature] = [
            .simple(
                name: "Dictionary",
                genericArguments: [
                    .simple(name: "Int"),
                    .simple(name: "String"),
                ]
            ),
            .simple(
                name: "Swift.Dictionary",
                genericArguments: [
                    .simple(name: "Int"),
                    .simple(name: "String"),
                ]
            ),
        ]

        XCTAssertNoDifference(
            [
                .dictionary(
                    key: .simple(name: "Int"),
                    value: .simple(name: "String")
                ),
                .dictionary(
                    key: .simple(name: "Int"),
                    value: .simple(name: "String")
                ),
            ],
            inputs.map { $0.inferLiteralTypes() }
        )
    }

    func testInferArrayLiteral() {
        let inputs: [TypeSignature] = [
            .simple(
                name: "Array",
                genericArguments: [
                    .simple(name: "Int")
                ]
            ),
            .simple(
                name: "Swift.Array",
                genericArguments: [
                    .simple(name: "Int")
                ]
            ),
        ]

        XCTAssertNoDifference(
            [
                .array(.simple(name: "Int")),
                .array(.simple(name: "Int")),
            ],
            inputs.map { $0.inferLiteralTypes() }
        )

    }

}
