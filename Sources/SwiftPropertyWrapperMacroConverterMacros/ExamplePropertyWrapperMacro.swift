//
//  ExamplePropertyWrapperMacro.swift
//  SwiftPropertyWrapperMacroConverter
//
//  Created by Annalise Mariottini on 9/19/25.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

// MARK: Macros

@_spi(ExampleMacros)
public struct ExamplePropertyWrapperMacro: PropertyWrapperMacro {}

@_spi(ExampleMacros)
public struct ExampleSettablePropertyWrapperMacro: PropertyWrapperMacro {
    public static var wrappedValueIsSettable: Bool { true }
    public static var isReferenceType: Bool { true }
}

@_spi(ExampleMacros)
public struct ExampleWithProjectedPropertyWrapperMacro: PropertyWrapperMacro {
    public static func projectedValueType(of _: AttributeSyntax,
                                          providingAccessorsOf _: some DeclSyntaxProtocol,
                                          in _: some MacroExpansionContext) -> TypeSyntax? { "Int" }
}

@_spi(ExampleMacros)
public struct ExampleWithSettableProjectedPropertyWrapperMacro: PropertyWrapperMacro {
    public static var projectedValueIsSettable: Bool { true }
    public static var isReferenceType: Bool { true }
    public static func projectedValueType(of _: AttributeSyntax,
                                          providingAccessorsOf _: some DeclSyntaxProtocol,
                                          in _: some MacroExpansionContext) -> TypeSyntax? { "Int" }
}

@_spi(ExampleMacros)
public struct ExampleWithWrappedValuePropertyWrapperMacro: PropertyWrapperMacro {}

// MARK: Property Wrappers

@_spi(ExampleMacros)
@propertyWrapper
public struct Example<Value: Sendable>: Sendable {
    public init(_ wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public let wrappedValue: Value
}

@_spi(ExampleMacros)
@propertyWrapper
public final class ExampleSettable<Value: Sendable>: @unchecked Sendable {
    public init(_ wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public var wrappedValue: Value
}

@_spi(ExampleMacros)
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

@_spi(ExampleMacros)
@propertyWrapper
public final class ExampleWithSettableProjected<Value: Hashable & Sendable>: @unchecked Sendable {
    public init(_ wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public var wrappedValue: Value
    public lazy var projectedValue: Int = wrappedValue.hashValue
}

@_spi(ExampleMacros)
@propertyWrapper
public struct ExampleWithWrappedValue<Value: Hashable & Sendable>: Sendable {
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public var wrappedValue: Value
}
