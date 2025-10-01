//
//  PropertyWrapperMacroDiagnostic.swift
//  Macrofy
//
//  Created by Annalise Mariottini on 9/19/25.
//

import Foundation
import SwiftDiagnostics

enum PropertyWrapperMacroDiagnostic: DiagnosticMessage {
    case unexpectedTypeDeclaration
    case unexpectedWrappedValueType
    case unexpectedProjectedValueType

    var rawValue: String {
        switch self {
        case .unexpectedTypeDeclaration: return "unexpected-type-declaration"
        case .unexpectedWrappedValueType: return "unexpected-wrapped-value-type"
        case .unexpectedProjectedValueType: return "unexpected-projected-value-type"
        }
    }

    var message: String {
        switch self {
        case .unexpectedTypeDeclaration: return "Macro can only be used on a variable declaration"
        case .unexpectedWrappedValueType: return "The wrappedValue of the original property wrapper must be a variable declaration with an explicit type"
        case .unexpectedProjectedValueType: return "The projectedValue of the original property wrapper must be a variable declaration with an explicit type"
        }
    }

    var diagnosticID: SwiftDiagnostics.MessageID {
        MessageID(domain: "ZDependencyInjectionMacros", id: rawValue)
    }

    var severity: SwiftDiagnostics.DiagnosticSeverity {
        switch self {
        case .unexpectedTypeDeclaration: return .error
        case .unexpectedWrappedValueType: return .error
        case .unexpectedProjectedValueType: return .error
        }
    }
}
