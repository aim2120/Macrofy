//
//  MacrofyMacro.swift
//  Macrofy
//
//  Created by Annalise Mariottini on 9/20/25.
//

import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `@macrofy` macro.
///
/// This macro analyzes a property wrapper type and generates a corresponding
/// `PropertyWrapperMacro` implementation that can be used to apply the property
/// wrapper behavior through macro expansion.
///
/// ## Analysis Process
///
/// The macro performs the following analysis:
/// 1. Validates the target is a supported declaration type (struct, class, actor, enum)
/// 2. Locates the required `wrappedValue` property
/// 3. Optionally locates a `projectedValue` property
/// 4. Determines mutability characteristics of both properties
/// 5. Generates a configuration struct with the analyzed characteristics
///
/// ## Generated Code
///
/// For a property wrapper like:
/// ```swift
/// @macrofy
/// @propertyWrapper
/// public struct MyWrapper<T> {
///     public var wrappedValue: T
///     public var projectedValue: String { "projected" }
/// }
/// ```
///
/// Generates:
/// ```swift
/// public struct MyWrapperMacro: PropertyWrapperMacro {
///     public struct Config: PropertyWrapperMacroConfig {
///         public init() {}
///         public let wrappedValueIsSettable = true
///         public func projectedValueType(...) -> TypeSyntax? { "String" }
///     }
/// }
/// ```
public struct MacrofyMacro: PeerMacro {
    public static func expansion(of node: AttributeSyntax,
                                 providingPeersOf declaration: some DeclSyntaxProtocol,
                                 in context: some MacroExpansionContext) throws -> [DeclSyntax]
    {
        func diagnose(_ diagnostic: MacrofyMacroDiagnostic) -> [DeclSyntax] {
            context.diagnose(Diagnostic(node: node, message: diagnostic))
            return []
        }
        guard let declaration = Declaration(declaration) else {
            return diagnose(.unsupportedDeclarationType)
        }

        let memberBlock = declaration.memberBlock
        let members = memberBlock.members
        let wrappedValue: (variableDecl: VariableDeclSyntax, binding: PatternBindingSyntax)? = members.firstVariable(withName: "wrappedValue")

        guard let wrappedValue else {
            return diagnose(.missingWrappedValue)
        }

        let projectedValue: (variableDecl: VariableDeclSyntax, binding: PatternBindingSyntax)? = members.firstVariable(withName: "projectedValue")

        let wrappedValueIsSettable = variableIsSettable(variableDecl: wrappedValue.variableDecl, binding: wrappedValue.binding)
        let projectedValueIsSettable: Bool?
        if let projectedValue {
            projectedValueIsSettable = variableIsSettable(variableDecl: projectedValue.variableDecl, binding: projectedValue.binding)
        } else {
            projectedValueIsSettable = nil
        }

        let configMembers = try MemberBlockItemListSyntax {
            DeclSyntax("""
            
            public init() { }
            
            """)

            if let projectedValue {
                if let projectedValueType = projectedValue.binding.typeAnnotation {
                    try FunctionDeclSyntax("""
                    
                    public func projectedValueType(of node: AttributeSyntax, providingAccessorsOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) -> TypeSyntax? { "\(projectedValueType.type.trimmed)" }
                    
                    """)
                }
                // TODO: handle when projected type annotation is missing
                // TODO: handle projected type with generics
            }
            if declaration.isReferenceType {
                try VariableDeclSyntax("""
                
                public let isReferenceType = true
                
                """)
            }
            if wrappedValueIsSettable {
                try VariableDeclSyntax("""
                
                public let wrappedValueIsSettable = true
                
                """)
            }
            if projectedValueIsSettable == true {
                try VariableDeclSyntax("""
                
                public let projectedValueIsSettable = true
                
                """)
            }
        }

        let config: DeclSyntax = """
        public struct Config: PropertyWrapperMacroConfig \(MemberBlockSyntax(members: configMembers))
        """

        return [
            """
            public struct \(declaration.name.trimmed)Macro: PropertyWrapperMacro {
                \(config)
            }
            """
        ]
    }

    private static func variableIsSettable(variableDecl: VariableDeclSyntax, binding: PatternBindingSyntax) -> Bool {
        // we can't use TokenSyntax equality here, because it uses an identifier from syntax tree
        let isLet = variableDecl.bindingSpecifier.trimmed.text == TokenSyntax.keyword(.let).text
        if isLet {
            return false
        }
        guard let accessorBlock = binding.accessorBlock else {
            // mutable var
            return true
        }
        guard case .accessors(let accessors) = accessorBlock.accessors else {
            // var with only getter
            return false
        }
        let containsSetter = accessors.contains(where: {
            $0.accessorSpecifier.trimmed.text == TokenSyntax.keyword(.set).text
        })
        return containsSetter
    }
}

private enum Declaration {
    init?(_ declSyntaxProtocol: some DeclSyntaxProtocol) {
        if let structDeclSyntax = declSyntaxProtocol.as(StructDeclSyntax.self) {
            self = .struct(structDeclSyntax)
            return
        } else if let classDeclSyntax = declSyntaxProtocol.as(ClassDeclSyntax.self) {
            self = .class(classDeclSyntax)
            return
        } else if let actorDeclSyntax = declSyntaxProtocol.as(ActorDeclSyntax.self) {
            self = .actor(actorDeclSyntax)
            return
        } else if let enumDeclSyntax = declSyntaxProtocol.as(EnumDeclSyntax.self) {
            self = .enum(enumDeclSyntax)
            return
        }
        return nil
    }

    case `struct`(StructDeclSyntax)
    case `class`(ClassDeclSyntax)
    case `actor`(ActorDeclSyntax)
    case `enum`(EnumDeclSyntax)

    var declSyntax: any DeclSyntaxProtocol {
        switch self {
        case .struct(let structDeclSyntax):
            return structDeclSyntax
        case .class(let classDeclSyntax):
            return classDeclSyntax
        case .actor(let actorDeclSyntax):
            return actorDeclSyntax
        case .enum(let enumDeclSyntax):
            return enumDeclSyntax
        }
    }

    var memberBlock: MemberBlockSyntax {
        switch self {
        case .struct(let structDeclSyntax):
            return structDeclSyntax.memberBlock
        case .class(let classDeclSyntax):
            return classDeclSyntax.memberBlock
        case .actor(let actorDeclSyntax):
            return actorDeclSyntax.memberBlock
        case .enum(let enumDeclSyntax):
            return enumDeclSyntax.memberBlock
        }
    }

    var name: TokenSyntax {
        switch self {
        case .struct(let structDeclSyntax):
            return structDeclSyntax.name
        case .class(let classDeclSyntax):
            return classDeclSyntax.name
        case .actor(let actorDeclSyntax):
            return actorDeclSyntax.name
        case .enum(let enumDeclSyntax):
            return enumDeclSyntax.name
        }
    }

    var isReferenceType: Bool {
        switch self {
        case .class, .actor:
            return true
        case .struct, .enum:
            return false
        }
    }
}

private extension MemberBlockItemListSyntax {
    func firstVariable(withName name: String) -> (variableDecl: VariableDeclSyntax, binding: PatternBindingSyntax)? {
        compactMap {
            $0.decl.as(VariableDeclSyntax.self)
        }
        .compactMap { variableDecl -> (VariableDeclSyntax, PatternBindingSyntax)? in
            let wrappedValueBinding = variableDecl.bindings.first(where: {
                $0.pattern.as(IdentifierPatternSyntax.self)?.identifier.text == name
            })
            guard let wrappedValueBinding else { return nil }
            return (variableDecl, wrappedValueBinding)
        }
        .first
    }
}
