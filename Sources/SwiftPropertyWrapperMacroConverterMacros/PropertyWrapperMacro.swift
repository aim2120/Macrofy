//
//  PropertyWrapperMacro.swift
//  SwiftPropertyWrapperMacroConverter
//
//  Created by Annalise Mariottini on 9/19/25.
//

import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public protocol PropertyWrapperMacro: AccessorMacro, PeerMacro {
    static var wrappedValueIsSettable: Bool { get }
    static var projectedValueIsSettable: Bool { get }
    static var isReferenceType: Bool { get }
    static func propertyWrapperType(of node: AttributeSyntax,
                                    providingAccessorsOf declaration: some DeclSyntaxProtocol,
                                    in context: some MacroExpansionContext) -> TypeSyntax
    static func projectedValueType(of node: AttributeSyntax,
                                   providingAccessorsOf declaration: some DeclSyntaxProtocol,
                                   in context: some MacroExpansionContext) -> TypeSyntax?
}

extension PropertyWrapperMacro {
    public static var wrappedValueIsSettable: Bool { false }
    public static var projectedValueIsSettable: Bool { false }
    public static var isReferenceType: Bool { false }
    public static func propertyWrapperType(of node: AttributeSyntax,
                                           providingAccessorsOf declaration: some DeclSyntaxProtocol,
                                           in context: some MacroExpansionContext) -> TypeSyntax {
        node.attributeName.trimmed
    }

    public static func projectedValueType(of node: AttributeSyntax,
                                                    providingAccessorsOf declaration: some DeclSyntaxProtocol,
                                                    in context: some MacroExpansionContext) -> TypeSyntax? {
        nil
    }

    public static func expansion(of node: AttributeSyntax,
                                 providingAccessorsOf declaration: some DeclSyntaxProtocol,
                                 in context: some MacroExpansionContext) throws -> [AccessorDeclSyntax] {
        func diagnose(_ diagnostic: PropertyWrapperMacroDiagnostic) -> [AccessorDeclSyntax] {
            context.diagnose(Diagnostic(node: node, message: diagnostic))
            return ["get { fatalError() }"]
        }

        guard let variableDecl = declaration.as(VariableDeclSyntax.self) else {
            return diagnose(.unexpectedTypeDeclaration)
        }
        guard let binding = variableDecl.bindings.first else {
            return diagnose(.unexpectedTypeDeclaration)
        }
        guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier else {
            return diagnose(.unexpectedTypeDeclaration)
        }
        var declSyntax: [AccessorDeclSyntax] = [
            "get { _\(identifier).wrappedValue }",
        ]
        if wrappedValueIsSettable {
            declSyntax.append(contentsOf: [
                "set { _\(identifier).wrappedValue = newValue }",
            ])
        }
        return declSyntax
    }
}

extension PropertyWrapperMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        func diagnose(_ diagnostic: PropertyWrapperMacroDiagnostic) -> [DeclSyntax] {
            context.diagnose(Diagnostic(node: node, message: diagnostic))
            return ["get { fatalError() }"]
        }

        guard let variableDecl = declaration.as(VariableDeclSyntax.self) else {
            return diagnose(.unexpectedTypeDeclaration)
        }
        guard let binding = variableDecl.bindings.first else {
            return diagnose(.unexpectedTypeDeclaration)
        }
        guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier else {
            return diagnose(.unexpectedTypeDeclaration)
        }

        var callExprArgs: [ExprSyntax] = []
        if let initializer = binding.initializer {
            callExprArgs.append("wrappedValue: \(initializer.value)")
        }
        if let arguments = node.arguments {
            callExprArgs.append("\(arguments)")
        }
        let callExpr: ExprSyntax = "(\(callExprArgs.joined(separator: ",")))"

        let letOrVar: ExprSyntax = (!isReferenceType && (wrappedValueIsSettable || projectedValueIsSettable)) ? "var" : "let"
        let propertyWrapperType = propertyWrapperType(of: node, providingAccessorsOf: declaration, in: context)
        var declSyntax: [DeclSyntax] = [
            "private \(letOrVar) _\(identifier) = \(propertyWrapperType)\(callExpr)",
        ]

        if let projectedValueType = projectedValueType(of: node, providingAccessorsOf: declaration, in: context) {
            declSyntax.append(contentsOf: [
                """
                \(variableDecl.modifiers)var $\(identifier): \(projectedValueType) {
                    get { _\(identifier).projectedValue }
                    \(projectedValueIsSettable ? "set { _\(identifier).projectedValue = newValue }" : "")
                }
                """
            ])
        }
        return declSyntax
    }
}

extension [ExprSyntax] {
    fileprivate func joined(separator: ExprSyntax = "") -> ExprSyntax {
        self.reduce("") {
            if "\($0)".isEmpty { return "\($1)" }
            return "\($0)\(separator)\($1)"
        }
    }
}
