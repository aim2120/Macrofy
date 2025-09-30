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
                                 providingPeersOf declSyntax: some DeclSyntaxProtocol,
                                 in context: some MacroExpansionContext) throws -> [DeclSyntax]
    {
        func diagnose(_ diagnostic: MacrofyMacroDiagnostic) -> [DeclSyntax] {
            context.diagnose(Diagnostic(node: node, message: diagnostic))
            return []
        }
        guard let declaration = Declaration(declSyntax) else {
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
        let projectedValueTypeResolver: ExprSyntax?
        if let projectedValue {
            projectedValueIsSettable = variableIsSettable(variableDecl: projectedValue.variableDecl, binding: projectedValue.binding)
            projectedValueTypeResolver = self.projectedValueTypeResolver(of: node, wrappedValue: wrappedValue, projectedValue: projectedValue, declaration: declaration, in: context)
        } else {
            projectedValueIsSettable = nil
            projectedValueTypeResolver = nil
        }

        let configMembers = try MemberBlockItemListSyntax {
            DeclSyntax("""

            public init() { }

            """)

            if let projectedValueTypeResolver {
                try FunctionDeclSyntax("""

                public func projectedValueType(of node: AttributeSyntax, providingAccessorsOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) -> TypeSyntax? {
                    \(projectedValueTypeResolver)
                }

                """)
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
            """,
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
        guard case let .accessors(accessors) = accessorBlock.accessors else {
            // var with only getter
            return false
        }
        let containsSetter = accessors.contains(where: {
            $0.accessorSpecifier.trimmed.text == TokenSyntax.keyword(.set).text
        })
        return containsSetter
    }

    private static func projectedValueTypeResolver(of node: AttributeSyntax,
                                                   wrappedValue: (variableDecl: VariableDeclSyntax, binding: PatternBindingSyntax),
                                                   projectedValue: (variableDecl: VariableDeclSyntax, binding: PatternBindingSyntax),
                                                   declaration: Declaration,
                                                   in context: some MacroExpansionContext) -> ExprSyntax?
    {
        func diagnose(_ diagnostic: MacrofyMacroDiagnostic) -> ExprSyntax? {
            context.diagnose(Diagnostic(node: node, message: diagnostic))
            return nil
        }

        guard let typeAnnotation = projectedValue.binding.typeAnnotation else {
            return diagnose(.missingProjectedValueType)
        }
        lazy var typeAsString: ExprSyntax = "\"\(typeAnnotation.type.trimmed)\""

        guard declaration.genericParameterClause != nil else {
            return typeAsString
        }

        // our property wrapper type has generics
        // to determine the projected value type, we need to use the helper function to evaluate the types
        // the helper function is defined in PropertyWrapperMacro.swift
        return """
        projectedValueType(
            of: node,
            originalWrappedValue: #\"""
            \(wrappedValue.variableDecl.trimmed)
            \"""#,
            originalProjectedValue: #\"""
            \(projectedValue.variableDecl.trimmed)
            \"""#,
            providingAccessorsOf: declaration,
            in: context
        )
        """
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
        case let .struct(structDeclSyntax):
            return structDeclSyntax
        case let .class(classDeclSyntax):
            return classDeclSyntax
        case let .actor(actorDeclSyntax):
            return actorDeclSyntax
        case let .enum(enumDeclSyntax):
            return enumDeclSyntax
        }
    }

    var memberBlock: MemberBlockSyntax {
        switch self {
        case let .struct(structDeclSyntax):
            return structDeclSyntax.memberBlock
        case let .class(classDeclSyntax):
            return classDeclSyntax.memberBlock
        case let .actor(actorDeclSyntax):
            return actorDeclSyntax.memberBlock
        case let .enum(enumDeclSyntax):
            return enumDeclSyntax.memberBlock
        }
    }

    var name: TokenSyntax {
        switch self {
        case let .struct(structDeclSyntax):
            return structDeclSyntax.name
        case let .class(classDeclSyntax):
            return classDeclSyntax.name
        case let .actor(actorDeclSyntax):
            return actorDeclSyntax.name
        case let .enum(enumDeclSyntax):
            return enumDeclSyntax.name
        }
    }

    var genericParameterClause: GenericParameterClauseSyntax? {
        switch self {
        case let .struct(structDeclSyntax):
            return structDeclSyntax.genericParameterClause
        case let .class(classDeclSyntax):
            return classDeclSyntax.genericParameterClause
        case let .actor(actorDeclSyntax):
            return actorDeclSyntax.genericParameterClause
        case let .enum(enumDeclSyntax):
            return enumDeclSyntax.genericParameterClause
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
            let binding = variableDecl.firstPatternBinding(withName: name)
            guard let binding else { return nil }
            return (variableDecl, binding)
        }
        .first
    }
}

private extension VariableDeclSyntax {
    func firstPatternBinding(withName name: String) -> PatternBindingSyntax? {
        bindings.first(where: {
            $0.pattern.as(IdentifierPatternSyntax.self)?.identifier.text == name
        })
    }
}
