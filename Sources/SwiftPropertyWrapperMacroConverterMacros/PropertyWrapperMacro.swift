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

public protocol PropertyWrapperMacroConfig {
    init()
    var wrappedValueIsSettable: Bool { get }
    var projectedValueIsSettable: Bool { get }
    var isReferenceType: Bool { get }
    func propertyWrapperType(of node: AttributeSyntax,
                             providingAccessorsOf declaration: some DeclSyntaxProtocol,
                             in context: some MacroExpansionContext) -> TypeSyntax
    func projectedValueType(of node: AttributeSyntax,
                            providingAccessorsOf declaration: some DeclSyntaxProtocol,
                            in context: some MacroExpansionContext) -> TypeSyntax?
}

public extension PropertyWrapperMacroConfig {
    var wrappedValueIsSettable: Bool { false }
    var projectedValueIsSettable: Bool { false }
    var isReferenceType: Bool { false }
    func propertyWrapperType(of node: AttributeSyntax,
                             providingAccessorsOf _: some DeclSyntaxProtocol,
                             in _: some MacroExpansionContext) -> TypeSyntax
    {
        node.attributeName.trimmed
    }

    func projectedValueType(of _: AttributeSyntax,
                            providingAccessorsOf _: some DeclSyntaxProtocol,
                            in _: some MacroExpansionContext) -> TypeSyntax?
    {
        nil
    }
}

public struct DefaultPropertyWrapperMacroConfig: PropertyWrapperMacroConfig {
    public init() {}
}

public protocol PropertyWrapperMacro: AccessorMacro, PeerMacro {
    associatedtype Config: PropertyWrapperMacroConfig
}

public extension PropertyWrapperMacro { // AccessorMacro
    static func expansion(of node: AttributeSyntax,
                          providingAccessorsOf declaration: some DeclSyntaxProtocol,
                          in context: some MacroExpansionContext) throws -> [AccessorDeclSyntax]
    {
        try expansion(using: Config(), of: node, providingAccessorsOf: declaration, in: context)
    }
}

public extension PropertyWrapperMacro { // PeerMacro
    static func expansion(of node: AttributeSyntax,
                          providingPeersOf declaration: some DeclSyntaxProtocol,
                          in context: some MacroExpansionContext) throws -> [DeclSyntax]
    {
        try expansion(using: Config(), of: node, providingPeersOf: declaration, in: context)
    }
}

public extension PropertyWrapperMacro {
    static func expansion(using config: any PropertyWrapperMacroConfig,
                          of node: AttributeSyntax,
                          providingAccessorsOf declaration: some DeclSyntaxProtocol,
                          in context: some MacroExpansionContext) throws -> [AccessorDeclSyntax]
    {
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
        if config.wrappedValueIsSettable {
            declSyntax.append(contentsOf: [
                "set { _\(identifier).wrappedValue = newValue }",
            ])
        }
        return declSyntax
    }
}

public extension PropertyWrapperMacro {
    static func expansion(
        using config: any PropertyWrapperMacroConfig,
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

        let letOrVar: ExprSyntax = (!config.isReferenceType && (config.wrappedValueIsSettable || config.projectedValueIsSettable)) ? "var" : "let"
        let propertyWrapperType = config.propertyWrapperType(of: node, providingAccessorsOf: declaration, in: context)
        var declSyntax: [DeclSyntax] = [
            "private \(letOrVar) _\(identifier) = \(propertyWrapperType)\(callExpr)",
        ]

        if let projectedValueType = config.projectedValueType(of: node, providingAccessorsOf: declaration, in: context) {
            declSyntax.append(contentsOf: [
                """
                \(variableDecl.modifiers)var $\(identifier): \(projectedValueType) {
                    get { _\(identifier).projectedValue }
                    \(config.projectedValueIsSettable ? "set { _\(identifier).projectedValue = newValue }" : "")
                }
                """,
            ])
        }
        return declSyntax
    }
}

private extension [ExprSyntax] {
    func joined(separator: ExprSyntax = "") -> ExprSyntax {
        self.reduce("") {
            if "\($0)".isEmpty { return "\($1)" }
            return "\($0)\(separator)\($1)"
        }
    }
}
