//
//  PropertyWrapperMacro.swift
//  Macrofy
//
//  Created by Annalise Mariottini on 9/19/25.
//

import Foundation
import MacrofyModels
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

// MARK: Config

/// Configuration protocol for ``PropertyWrapperMacro`` implementations.
///
/// This protocol defines the configuration interface for property wrapper macros,
/// allowing customization of how the macro generates accessor and peer declarations.
/// ```
public protocol PropertyWrapperMacroConfig {
    /// Required initializer for creating configuration instances.
    init()

    /// Indicates whether the property wrapper's `wrappedValue` is settable.
    ///
    /// When `true`, the macro generates both getter and setter accessors.
    /// When `false`, only a getter is generated.
    var wrappedValueIsSettable: Bool { get }

    /// Indicates whether the property wrapper's `projectedValue` is settable.
    ///
    /// When `true`, the macro generates both getter and setter for the projected value.
    /// When `false`, only a getter is generated for the projected value.
    var projectedValueIsSettable: Bool { get }

    /// Indicates whether the property wrapper is a reference type (class or actor).
    ///
    /// This affects whether the backing storage is declared as `let` or `var`.
    var isReferenceType: Bool { get }

    /// Determines the property wrapper type to use in the generated code.
    ///
    /// The arguments of this function are the same as the arguments to the top-level macro.
    ///
    /// - Parameters:
    ///   - node: The macro attribute syntax node
    ///   - declaration: The declaration being processed
    ///   - context: The macro expansion context
    /// - Returns: The type syntax for the property wrapper
    func propertyWrapperType(of node: AttributeSyntax,
                             providingAccessorsOf declaration: some DeclSyntaxProtocol,
                             in context: some MacroExpansionContext) -> TypeSyntax

    /// Determines the projected value type, if any.
    ///
    /// The arguments of this function are the same as the arguments to the top-level macro.
    ///
    /// - Parameters:
    ///   - node: The macro attribute syntax node
    ///   - declaration: The declaration being processed
    ///   - context: The macro expansion context
    /// - Returns: The type syntax for the projected value, or `nil` if none
    func projectedValueType(of node: AttributeSyntax,
                            providingAccessorsOf declaration: some DeclSyntaxProtocol,
                            in context: some MacroExpansionContext) -> TypeSyntax?
}

public extension PropertyWrapperMacroConfig {
    /// Default implementation returns `false`, making wrapped values read-only.
    var wrappedValueIsSettable: Bool { false }

    /// Default implementation returns `false`, making projected values read-only.
    var projectedValueIsSettable: Bool { false }

    /// Default implementation returns `false`, assuming value types.
    var isReferenceType: Bool { false }

    /// Default implementation uses the macro's attribute name as the property wrapper type.
    ///
    /// For example, `@MyWrapper` becomes `MyWrapper`.
    func propertyWrapperType(of node: AttributeSyntax,
                             providingAccessorsOf _: some DeclSyntaxProtocol,
                             in _: some MacroExpansionContext) -> TypeSyntax
    {
        node.attributeName.trimmed
    }

    /// Default implementation returns `nil`, indicating no projected value.
    func projectedValueType(of _: AttributeSyntax,
                            providingAccessorsOf _: some DeclSyntaxProtocol,
                            in _: some MacroExpansionContext) -> TypeSyntax?
    {
        nil
    }
}

/// Default configuration for property wrapper macros.
///
/// This configuration uses all the default implementations from ``PropertyWrapperMacroConfig``.
public struct DefaultPropertyWrapperMacroConfig: PropertyWrapperMacroConfig {
    public init() {}
}

// MARK: Macro

/// Protocol for property wrapper macros.
///
/// This protocol combines `AccessorMacro` and `PeerMacro` to provide complete
/// property wrapper functionality. It generates both the accessor methods
/// and the backing storage for property wrapper usage.
///
/// ## Usage
///
/// ```swift
/// public struct MyWrapperMacro: PropertyWrapperMacro {
///     public struct Config: PropertyWrapperMacroConfig {
///         public init() {}
///         public let wrappedValueIsSettable = true
///     }
/// }
/// ```
///
/// The macro will automatically generate:
/// - Private backing storage (`_propertyName`)
/// - Accessor methods (get/set) for the property (using `wrappedValue`)
/// - Projected value accessor (`$propertyName`) if configured
public protocol PropertyWrapperMacro: AccessorMacro, PeerMacro {
    /// Configuration type that defines the macro's behavior.
    associatedtype Config: PropertyWrapperMacroConfig
}

public extension PropertyWrapperMacro { // AccessorMacro
    /// The default implementation of `AccessorMacro`, which simply forward the macro's ``Config`` to ``expansion(using:of:providingAccessorsOf:in:)``.
    ///
    /// If you would like to provide additional customization to your macro, you may implement this yourself.
    static func expansion(of node: AttributeSyntax,
                          providingAccessorsOf declaration: some DeclSyntaxProtocol,
                          in context: some MacroExpansionContext) throws -> [AccessorDeclSyntax]
    {
        try expansion(using: Config(), of: node, providingAccessorsOf: declaration, in: context)
    }
}

public extension PropertyWrapperMacro { // PeerMacro
    /// The default implementation of `PeerMacro`, which simply forward the macro's ``Config`` to ``expansion(using:of:providingPeersOf:in:)``.
    ///
    /// If you would like to provide additional customization to your macro, you may implement this yourself.
    static func expansion(of node: AttributeSyntax,
                          providingPeersOf declaration: some DeclSyntaxProtocol,
                          in context: some MacroExpansionContext) throws -> [DeclSyntax]
    {
        try expansion(using: Config(), of: node, providingPeersOf: declaration, in: context)
    }
}

public extension PropertyWrapperMacro {
    /// Generates accessor declarations using a specific configuration.
    ///
    /// This method creates the get/set accessors that delegate to the property wrapper's
    /// `wrappedValue`. The behavior is controlled by the provided configuration.
    ///
    /// - Parameters:
    ///   - config: Configuration defining the macro's behavior
    ///   - node: The macro attribute syntax
    ///   - declaration: The property declaration being processed
    ///   - context: The macro expansion context
    /// - Returns: Array of accessor declarations
    /// - Throws: MacroExpansionError if the declaration is invalid
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

    /// Generates peer declarations using a specific configuration.
    ///
    /// This method creates the backing storage and projected value accessor for the
    /// property wrapper. The generated code includes:
    /// - Private backing storage (`_propertyName`)
    /// - Projected value accessor (`$propertyName`) if configured
    ///
    /// - Parameters:
    ///   - config: Configuration defining the macro's behavior
    ///   - node: The macro attribute syntax
    ///   - declaration: The property declaration being processed
    ///   - context: The macro expansion context
    /// - Returns: Array of peer declarations
    /// - Throws: MacroExpansionError if the declaration is invalid
    static func expansion(
        using config: any PropertyWrapperMacroConfig,
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        func diagnose(_ diagnostic: PropertyWrapperMacroDiagnostic) -> [DeclSyntax] {
            context.diagnose(Diagnostic(node: node, message: diagnostic))
            return []
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

        var callExprArgs: [String] = []
        if let initializer = binding.initializer {
            callExprArgs.append("wrappedValue: \(initializer.value)")
        }
        if let arguments = node.arguments {
            callExprArgs.append("\(arguments)")
        }
        let callExpr: ExprSyntax = "(\(raw: callExprArgs.joined(separator: ",")))"

        let letOrVar: TokenSyntax = (!config.isReferenceType && (config.wrappedValueIsSettable || config.projectedValueIsSettable)) ? "var" : "let"
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

// MARK: Projected Value Helpers

public extension PropertyWrapperMacroConfig {
    /// Resolves the projected value type for generic property wrappers by mapping generic type parameters to their concrete types.
    ///
    /// This function is used when the property wrapper contains generic parameters and the projected value type
    /// needs to be resolved based on the actual concrete types used in the variable declaration. It performs
    /// type mapping by comparing the original generic declarations with the annotated concrete types.
    ///
    /// ## Usage
    /// 
    /// This function is primarily called by the `MacrofyMacro` when generating property wrapper macros that
    /// contain generic projected values. For example, when transforming:
    /// 
    /// ```swift
    /// @propertyWrapper
    /// struct MyWrapper<Value> {
    ///     let wrappedValue: Value
    ///     let projectedValue: Binding<Value>
    /// }
    /// ```
    /// 
    /// Used with a concrete type like `@MyWrapper var name: String`, this function will resolve
    /// `Binding<Value>` to `Binding<String>`.
    ///
    /// ## Type Mapping Process
    /// 
    /// 1. Extracts type trees from the original wrapped and projected value declarations
    /// 2. Creates a type tree from the concrete variable declaration
    /// 3. Builds a mapping from generic types to concrete types by comparing type trees
    /// 4. Applies the mapping to transform the projected value type
    ///
    /// - Parameters:
    ///   - node: The macro attribute syntax node for diagnostic reporting
    ///   - originalWrappedValue: The original wrapped value declaration from the property wrapper definition
    ///   - originalProjectedValue: The original projected value declaration from the property wrapper definition
    ///   - declaration: The concrete variable declaration being processed with specific type annotations
    ///   - context: The macro expansion context for diagnostic reporting and type resolution
    /// - Returns: The resolved projected value type with generic parameters substituted, or `nil` if resolution fails
    /// - Note: Returns `nil` and emits diagnostics for malformed declarations or unsupported type structures
    func projectedValueType(of node: AttributeSyntax,
                            originalWrappedValue: DeclSyntax,
                            originalProjectedValue: DeclSyntax,
                            providingAccessorsOf declaration: some DeclSyntaxProtocol,
                            in context: some MacroExpansionContext) -> TypeSyntax?
    {
        func diagnose(_ diagnostic: PropertyWrapperMacroDiagnostic) -> TypeSyntax? {
            context.diagnose(Diagnostic(node: node, message: diagnostic))
            return nil
        }

        guard let originalWrappedValueTypeTree = originalWrappedValue.as(VariableDeclSyntax.self)?.bindings.first?.typeAnnotation?.type.as(IdentifierTypeSyntax.self).map(TypeTree.init) else {
            return diagnose(.unexpectedWrappedValueType)
        }
        guard let originalProjectedValueTypeTree = originalProjectedValue.as(VariableDeclSyntax.self)?.bindings.first?.typeAnnotation?.type.as(IdentifierTypeSyntax.self).map(TypeTree.init) else {
            return diagnose(.unexpectedProjectedValueType)
        }

        guard let variableDecl = declaration.as(VariableDeclSyntax.self) else {
            return diagnose(.unexpectedTypeDeclaration)
        }
        guard let typeAnnotation = variableDecl.bindings.first?.typeAnnotation else {
            return diagnose(.unexpectedTypeDeclaration)
        }
        guard let identifierType = typeAnnotation.type.as(IdentifierTypeSyntax.self) else {
            return diagnose(.unexpectedTypeDeclaration)
        }

        let annotatedTypeTree = TypeTree(identifierType)

        var originalToAnnotatedTypeMap: [String: String] = [:]
        for (originalType, annotatedType) in zip(originalWrappedValueTypeTree, annotatedTypeTree) where originalType.type != annotatedType.type {
            originalToAnnotatedTypeMap[originalType.type] = annotatedType.type
        }

        let projectedValueType = originalToAnnotatedTypeMap.reduce(originalProjectedValueTypeTree) { typeTree, type in
            typeTree.replacing(type: type.key, with: type.value)
        }

        return projectedValueType.typeSyntax
    }
}
