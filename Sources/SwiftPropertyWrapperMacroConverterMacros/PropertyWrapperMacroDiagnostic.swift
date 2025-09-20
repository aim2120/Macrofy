//
//  PropertyWrapperMacroDiagnostic.swift
//  SwiftPropertyWrapperMacroConverter
//
//  Created by Annalise Mariottini on 9/19/25.
//

import Foundation
import SwiftDiagnostics

enum PropertyWrapperMacroDiagnostic: DiagnosticMessage {
    case unexpectedTypeDeclaration

    var rawValue: String  {
        switch self {
        case .unexpectedTypeDeclaration: return "unexpected-type-declaration"
        }
    }

    var message: String {
        switch self {
        case .unexpectedTypeDeclaration: return "Macro can only be used on a variable declaration"
        }
    }

    var diagnosticID: SwiftDiagnostics.MessageID {
        MessageID(domain: "ZDependencyInjectionMacros", id: rawValue)
    }

    var severity: SwiftDiagnostics.DiagnosticSeverity {
        switch self {
        case .unexpectedTypeDeclaration: return .error
        }
    }
}
