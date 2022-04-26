//
//  File.swift
//
//
//  Created by Simon Anreiter on 26.04.22.
//

import Foundation
@_implementationOnly import SwiftSyntax

extension SyntaxProtocol {

    var trimmed: String {
        withoutTrivia().description
    }
}
