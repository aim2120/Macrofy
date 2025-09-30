//
//  IdentifierTypeSyntax+NestedGenericTypes.swift
//  Macrofy
//
//  Created by Annalise Mariottini on 9/26/25.
//

import SwiftSyntax
import SwiftSyntaxBuilder

extension IdentifierTypeSyntax {
    var nestedGenericTypes: [TokenSyntax] {
        guard let genericArgumentClause = genericArgumentClause else {
            return []
        }
        let arguments = genericArgumentClause.arguments
        return arguments.reduce([]) { arr, arg in
            guard let identifierTypeSyntax = arg.argument.as(IdentifierTypeSyntax.self) else {
                assertionFailure("Unexpected type that is not IdentifierTypeSyntax: \(arg.argument)")
                return arr
            }
            return arr + [identifierTypeSyntax.name] + identifierTypeSyntax.nestedGenericTypes
        }
    }
}
