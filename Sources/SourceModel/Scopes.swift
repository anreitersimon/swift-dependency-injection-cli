//
//  File.swift
//
//
//  Created by Simon Anreiter on 25.04.22.
//

import Foundation

protocol DeclarationScope {
    var path: String { get }
    var types: [TypeDeclaration] { get set }
    
    var initializers: [Initializer] { get set }
    var variables: [Variable] { get set }
    var functions: [Function] { get set }
}
