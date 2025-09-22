//
//  ExamplePropertyWrapperMacros.swift
//  Macrofy
//
//  Created by Annalise Mariottini on 9/19/25.
//

import Macrofy
import SwiftSyntax
import SwiftSyntaxMacros

@macrofy
@propertyWrapper
public struct Example<Value: Sendable>: Sendable {
    public init(_ wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public let wrappedValue: Value
}

@macrofy
@propertyWrapper
public final class ExampleSettable<Value: Sendable>: @unchecked Sendable {
    public init(_ wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public var wrappedValue: Value
}

@macrofy
@propertyWrapper
public struct ExampleWithProjected<Value: Hashable & Sendable>: Sendable {
    public init(_ wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public let wrappedValue: Value
    public var projectedValue: Int {
        wrappedValue.hashValue
    }
}

@macrofy
@propertyWrapper
public final class ExampleWithSettableProjected<Value: Hashable & Sendable>: @unchecked Sendable {
    public init(_ wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public let wrappedValue: Value
    public lazy var projectedValue: Int = wrappedValue.hashValue
}

@macrofy
@propertyWrapper
public struct ExampleWithWrappedValue<Value: Hashable & Sendable>: Sendable {
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    public let wrappedValue: Value
}
