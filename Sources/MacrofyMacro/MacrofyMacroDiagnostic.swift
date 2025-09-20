//
//  MacrofyMacroDiagnostic.swift
//  Macrofy
//
//  Created by Annalise Mariottini on 9/20/25.
//

import Foundation
import SwiftDiagnostics

enum MacrofyMacroDiagnostic: DiagnosticMessage {
    static let macroName = "@macrofy"

    case unsupportedDeclarationType
    case missingWrappedValue

    var rawValue: String {
        switch self {
        case .unsupportedDeclarationType: return "unsupported_declaration"
        case .missingWrappedValue: return "missing_wrapped_value"
        }
    }

    var message: String {
        switch self {
        case .unsupportedDeclarationType: return "The \(Self.macroName) macro can only be used on a struct, class, actor, or enum."
        case .missingWrappedValue: return "A property wrapper must have a wrappedValue member."
        }
    }

    var diagnosticID: SwiftDiagnostics.MessageID {
        MessageID(domain: "ZDependencyInjectionMacros", id: rawValue)
    }

    var severity: SwiftDiagnostics.DiagnosticSeverity {
        switch self {
        case .unsupportedDeclarationType: return .error
        case .missingWrappedValue: return .error
        }
    }
}
