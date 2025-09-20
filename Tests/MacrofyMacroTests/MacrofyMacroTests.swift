//
//  MacrofyMacroTests.swift
//  Macrofy
//
//  Created by Annalise Mariottini on 9/20/25.
//

import Foundation

import XCTest

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport

import MacrofyMacro

final class MacrofyMacroTests: XCTestCase {
    let testMacros: [String: Macro.Type] = [
        "macrofy": MacrofyMacro.self,
    ]

    func testMacrofyMacro_struct() async throws {
        let original = """
        @macrofy
        @propertyWrapper
        struct MyPropertyWrapper {
            let wrappedValue: String
        }
        """
        let expected = """
        @propertyWrapper
        struct MyPropertyWrapper {
            let wrappedValue: String
        }
        
        public struct MyPropertyWrapperMacro: PropertyWrapperMacro {
            public struct Config: PropertyWrapperMacroConfig {
            public init() {
            }
            }
        }
        """

        assertMacroExpansion(original, expandedSource: expected, macros: testMacros)
    }

    func testMacrofyMacro_class() async throws {
        let original = """
        @macrofy
        @propertyWrapper
        class MyPropertyWrapper {
            let wrappedValue: String
        }
        """
        let expected = """
        @propertyWrapper
        class MyPropertyWrapper {
            let wrappedValue: String
        }
        
        public struct MyPropertyWrapperMacro: PropertyWrapperMacro {
            public struct Config: PropertyWrapperMacroConfig {
            public init() {
            }
        
            public let isReferenceType = true
            }
        }
        """

        assertMacroExpansion(original, expandedSource: expected, macros: testMacros)
    }

    func testMacrofyMacro_finalClass() async throws {
        let original = """
        @macrofy
        @propertyWrapper
        final class MyPropertyWrapper {
            let wrappedValue: String
        }
        """
        let expected = """
        @propertyWrapper
        final class MyPropertyWrapper {
            let wrappedValue: String
        }
        
        public struct MyPropertyWrapperMacro: PropertyWrapperMacro {
            public struct Config: PropertyWrapperMacroConfig {
            public init() {
            }
        
            public let isReferenceType = true
            }
        }
        """

        assertMacroExpansion(original, expandedSource: expected, macros: testMacros)
    }

    func testMacrofyMacro_actor() async throws {
        let original = """
        @macrofy
        @propertyWrapper
        actor MyPropertyWrapper {
            let wrappedValue: String
        }
        """
        let expected = """
        @propertyWrapper
        actor MyPropertyWrapper {
            let wrappedValue: String
        }
        
        public struct MyPropertyWrapperMacro: PropertyWrapperMacro {
            public struct Config: PropertyWrapperMacroConfig {
            public init() {
            }
        
            public let isReferenceType = true
            }
        }
        """

        assertMacroExpansion(original, expandedSource: expected, macros: testMacros)
    }

    func testMacrofyMacro_enum() async throws {
        let original = """
        @macrofy
        @propertyWrapper
        enum MyPropertyWrapper {
            let wrappedValue: String
        }
        """
        let expected = """
        @propertyWrapper
        enum MyPropertyWrapper {
            let wrappedValue: String
        }
        
        public struct MyPropertyWrapperMacro: PropertyWrapperMacro {
            public struct Config: PropertyWrapperMacroConfig {
            public init() {
            }
            }
        }
        """

        assertMacroExpansion(original, expandedSource: expected, macros: testMacros)
    }

    // MARK: Wrapped Value Settable

    func testMacrofyMacro_immutableWrappedValue_let_noInitializer() async throws {
        let original = """
        @macrofy
        @propertyWrapper
        struct MyPropertyWrapper {
            let wrappedValue: String
        }
        """
        let expected = """
        @propertyWrapper
        struct MyPropertyWrapper {
            let wrappedValue: String
        }
        
        public struct MyPropertyWrapperMacro: PropertyWrapperMacro {
            public struct Config: PropertyWrapperMacroConfig {
            public init() {
            }
            }
        }
        """

        assertMacroExpansion(original, expandedSource: expected, macros: testMacros)
    }

    func testMacrofyMacro_immutableWrappedValue_let_withInitializer() async throws {
        let original = """
        @macrofy
        @propertyWrapper
        struct MyPropertyWrapper {
            let wrappedValue: String = "hello"
        }
        """
        let expected = """
        @propertyWrapper
        struct MyPropertyWrapper {
            let wrappedValue: String = "hello"
        }
        
        public struct MyPropertyWrapperMacro: PropertyWrapperMacro {
            public struct Config: PropertyWrapperMacroConfig {
            public init() {
            }
            }
        }
        """

        assertMacroExpansion(original, expandedSource: expected, macros: testMacros)
    }

    func testMacrofyMacro_immutableWrappedValue_var_getterWithoutGet() async throws {
        let original = """
        @macrofy
        @propertyWrapper
        struct MyPropertyWrapper {
            var wrappedValue: String { "hello" }
        }
        """
        let expected = """
        @propertyWrapper
        struct MyPropertyWrapper {
            var wrappedValue: String { "hello" }
        }
        
        public struct MyPropertyWrapperMacro: PropertyWrapperMacro {
            public struct Config: PropertyWrapperMacroConfig {
            public init() {
            }
            }
        }
        """

        assertMacroExpansion(original, expandedSource: expected, macros: testMacros)
    }

    func testMacrofyMacro_immutableWrappedValue_var_getterWithGet() async throws {
        let original = """
        @macrofy
        @propertyWrapper
        struct MyPropertyWrapper {
            var wrappedValue: String { get { "hello" } }
        }
        """
        let expected = """
        @propertyWrapper
        struct MyPropertyWrapper {
            var wrappedValue: String { get { "hello" } }
        }
        
        public struct MyPropertyWrapperMacro: PropertyWrapperMacro {
            public struct Config: PropertyWrapperMacroConfig {
            public init() {
            }
            }
        }
        """

        assertMacroExpansion(original, expandedSource: expected, macros: testMacros)
    }

    func testMacrofyMacro_mutableWrappedValue_var_noInitializer() async throws {
        let original = """
        @macrofy
        @propertyWrapper
        struct MyPropertyWrapper {
            var wrappedValue: String
        }
        """
        let expected = """
        @propertyWrapper
        struct MyPropertyWrapper {
            var wrappedValue: String
        }
        
        public struct MyPropertyWrapperMacro: PropertyWrapperMacro {
            public struct Config: PropertyWrapperMacroConfig {
            public init() {
            }
        
            public let wrappedValueIsSettable = true
            }
        }
        """

        assertMacroExpansion(original, expandedSource: expected, macros: testMacros)
    }

    func testMacrofyMacro_mutableWrappedValue_var_withInitializer() async throws {
        let original = """
        @macrofy
        @propertyWrapper
        struct MyPropertyWrapper {
            var wrappedValue: String = "hello"
        }
        """
        let expected = """
        @propertyWrapper
        struct MyPropertyWrapper {
            var wrappedValue: String = "hello"
        }
        
        public struct MyPropertyWrapperMacro: PropertyWrapperMacro {
            public struct Config: PropertyWrapperMacroConfig {
            public init() {
            }
        
            public let wrappedValueIsSettable = true
            }
        }
        """

        assertMacroExpansion(original, expandedSource: expected, macros: testMacros)
    }

    func testMacrofyMacro_mutableWrappedValue_var_getterAndSetter() async throws {
        let original = """
        @macrofy
        @propertyWrapper
        struct MyPropertyWrapper {
            var wrappedValue: String {
                get { backingValue }
                set { backingValue = newValue }
            }
            var backingValue: String
        }
        """
        let expected = """
        @propertyWrapper
        struct MyPropertyWrapper {
            var wrappedValue: String {
                get { backingValue }
                set { backingValue = newValue }
            }
            var backingValue: String
        }
        
        public struct MyPropertyWrapperMacro: PropertyWrapperMacro {
            public struct Config: PropertyWrapperMacroConfig {
            public init() {
            }
        
            public let wrappedValueIsSettable = true
            }
        }
        """

        assertMacroExpansion(original, expandedSource: expected, macros: testMacros)
    }

    // MARK: Projected Value Settable

    func testMacrofyMacro_immutableProjectedValue_let_noInitializer() async throws {
        let original = """
        @macrofy
        @propertyWrapper
        struct MyPropertyWrapper {
            let wrappedValue: String
            let projectedValue: String
        }
        """
        let expected = """
        @propertyWrapper
        struct MyPropertyWrapper {
            let wrappedValue: String
            let projectedValue: String
        }
        
        public struct MyPropertyWrapperMacro: PropertyWrapperMacro {
            public struct Config: PropertyWrapperMacroConfig {
            public init() {
            }
        
            public func projectedValueType(of node: AttributeSyntax, providingAccessorsOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) -> TypeSyntax? {
                "String"
            }
            }
        }
        """

        assertMacroExpansion(original, expandedSource: expected, macros: testMacros)
    }

    func testMacrofyMacro_immutableProjectedValue_let_withInitializer() async throws {
        let original = """
        @macrofy
        @propertyWrapper
        struct MyPropertyWrapper {
            let wrappedValue: String
            let projectedValue: String = "hello"
        }
        """
        let expected = """
        @propertyWrapper
        struct MyPropertyWrapper {
            let wrappedValue: String
            let projectedValue: String = "hello"
        }
        
        public struct MyPropertyWrapperMacro: PropertyWrapperMacro {
            public struct Config: PropertyWrapperMacroConfig {
            public init() {
            }
        
            public func projectedValueType(of node: AttributeSyntax, providingAccessorsOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) -> TypeSyntax? {
                "String"
            }
            }
        }
        """

        assertMacroExpansion(original, expandedSource: expected, macros: testMacros)
    }

    func testMacrofyMacro_immutableProjectedValue_var_getterWithoutGet() async throws {
        let original = """
        @macrofy
        @propertyWrapper
        struct MyPropertyWrapper {
            let wrappedValue: String
            var projectedValue: String { "hello" }
        }
        """
        let expected = """
        @propertyWrapper
        struct MyPropertyWrapper {
            let wrappedValue: String
            var projectedValue: String { "hello" }
        }
        
        public struct MyPropertyWrapperMacro: PropertyWrapperMacro {
            public struct Config: PropertyWrapperMacroConfig {
            public init() {
            }
        
            public func projectedValueType(of node: AttributeSyntax, providingAccessorsOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) -> TypeSyntax? {
                "String"
            }
            }
        }
        """

        assertMacroExpansion(original, expandedSource: expected, macros: testMacros)
    }

    func testMacrofyMacro_immutableProjectedValue_var_getterWithGet() async throws {
        let original = """
        @macrofy
        @propertyWrapper
        struct MyPropertyWrapper {
            let wrappedValue: String
            var projectedValue: String { get { "hello" } }
        }
        """
        let expected = """
        @propertyWrapper
        struct MyPropertyWrapper {
            let wrappedValue: String
            var projectedValue: String { get { "hello" } }
        }
        
        public struct MyPropertyWrapperMacro: PropertyWrapperMacro {
            public struct Config: PropertyWrapperMacroConfig {
            public init() {
            }
        
            public func projectedValueType(of node: AttributeSyntax, providingAccessorsOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) -> TypeSyntax? {
                "String"
            }
            }
        }
        """

        assertMacroExpansion(original, expandedSource: expected, macros: testMacros)
    }

    func testMacrofyMacro_mutableProjectedValue_var_noInitializer() async throws {
        let original = """
        @macrofy
        @propertyWrapper
        struct MyPropertyWrapper {
            let wrappedValue: String
            var projectedValue: String
        }
        """
        let expected = """
        @propertyWrapper
        struct MyPropertyWrapper {
            let wrappedValue: String
            var projectedValue: String
        }
        
        public struct MyPropertyWrapperMacro: PropertyWrapperMacro {
            public struct Config: PropertyWrapperMacroConfig {
            public init() {
            }
        
            public func projectedValueType(of node: AttributeSyntax, providingAccessorsOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) -> TypeSyntax? {
                "String"
            }
        
            public let projectedValueIsSettable = true
            }
        }
        """

        assertMacroExpansion(original, expandedSource: expected, macros: testMacros)
    }

    func testMacrofyMacro_mutableProjectedValue_var_withInitializer() async throws {
        let original = """
        @macrofy
        @propertyWrapper
        struct MyPropertyWrapper {
            let wrappedValue: String
            var projectedValue: String = "hello"
        }
        """
        let expected = """
        @propertyWrapper
        struct MyPropertyWrapper {
            let wrappedValue: String
            var projectedValue: String = "hello"
        }
        
        public struct MyPropertyWrapperMacro: PropertyWrapperMacro {
            public struct Config: PropertyWrapperMacroConfig {
            public init() {
            }
        
            public func projectedValueType(of node: AttributeSyntax, providingAccessorsOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) -> TypeSyntax? {
                "String"
            }
        
            public let projectedValueIsSettable = true
            }
        }
        """

        assertMacroExpansion(original, expandedSource: expected, macros: testMacros)
    }

    func testMacrofyMacro_mutableProjectedValue_var_getterAndSetter() async throws {
        let original = """
        @macrofy
        @propertyWrapper
        struct MyPropertyWrapper {
            let wrappedValue: String
            var projectedValue: String {
                get { backingValue }
                set { backingValue = newValue }
            }
            var backingValue: String
        }
        """
        let expected = """
        @propertyWrapper
        struct MyPropertyWrapper {
            let wrappedValue: String
            var projectedValue: String {
                get { backingValue }
                set { backingValue = newValue }
            }
            var backingValue: String
        }
        
        public struct MyPropertyWrapperMacro: PropertyWrapperMacro {
            public struct Config: PropertyWrapperMacroConfig {
            public init() {
            }
        
            public func projectedValueType(of node: AttributeSyntax, providingAccessorsOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) -> TypeSyntax? {
                "String"
            }
        
            public let projectedValueIsSettable = true
            }
        }
        """

        assertMacroExpansion(original, expandedSource: expected, macros: testMacros)
    }
}
