//
//  ExamplePropertyWrapperMacros.swift
//  Macrofy
//
//  Created by Annalise Mariottini on 9/19/25.
//

import Foundation
import PropertyWrapperMacro
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: Macros

public struct ExamplePropertyWrapperMacro: PropertyWrapperMacro {
    public typealias Config = DefaultPropertyWrapperMacroConfig
}

public struct ExampleSettablePropertyWrapperMacro: PropertyWrapperMacro {
    public struct Config: PropertyWrapperMacroConfig {
        public init() {}
        public let wrappedValueIsSettable: Bool = true
        public let isReferenceType: Bool = true
    }
}

public struct ExampleWithProjectedPropertyWrapperMacro: PropertyWrapperMacro {
    public struct Config: PropertyWrapperMacroConfig {
        public init() {}
        public func projectedValueType(of _: AttributeSyntax,
                                       providingAccessorsOf _: some DeclSyntaxProtocol,
                                       in _: some MacroExpansionContext) -> TypeSyntax? { "Int" }
    }
}

public struct ExampleWithSettableProjectedPropertyWrapperMacro: PropertyWrapperMacro {
    public struct Config: PropertyWrapperMacroConfig {
        public init() {}
        public let projectedValueIsSettable: Bool = true
        public let isReferenceType: Bool = true
        public func projectedValueType(of _: AttributeSyntax,
                                       providingAccessorsOf _: some DeclSyntaxProtocol,
                                       in _: some MacroExpansionContext) -> TypeSyntax? { "Int" }
    }
}

public struct ExampleWithWrappedValuePropertyWrapperMacro: PropertyWrapperMacro {
    public typealias Config = DefaultPropertyWrapperMacroConfig
}

// MARK: Property Wrappers

@propertyWrapper
public struct Example<Value: Sendable>: Sendable {
    public init(_ wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public let wrappedValue: Value
}

@propertyWrapper
public final class ExampleSettable<Value: Sendable>: @unchecked Sendable {
    public init(_ wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public var wrappedValue: Value
}

@propertyWrapper
public struct ExampleWithProjected<Value: Hashable & Sendable>: Sendable {
    public init(_ wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public var wrappedValue: Value
    public var projectedValue: Int {
        wrappedValue.hashValue
    }
}

@propertyWrapper
public final class ExampleWithSettableProjected<Value: Hashable & Sendable>: @unchecked Sendable {
    public init(_ wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public var wrappedValue: Value
    public lazy var projectedValue: Int = wrappedValue.hashValue
}

@propertyWrapper
public struct ExampleWithWrappedValue<Value: Hashable & Sendable>: Sendable {
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public var wrappedValue: Value
}
