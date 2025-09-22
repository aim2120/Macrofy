//
//  Macrofy.swift
//  Macrofy
//
//  Created by Annalise Mariottini on 9/20/25.
//

import Foundation
@_exported import PropertyWrapperMacro

/// Automatically generates a property wrapper macro from a property wrapper type.
///
/// The `@macrofy` macro analyzes your property wrapper type and generates a corresponding
/// macro that can be used to apply the property wrapper with proper accessor handling.
///
/// ## Usage
///
/// Apply `@macrofy` to any property wrapper type:
///
/// ```swift
/// @macrofy
/// @propertyWrapper
/// public struct MyWrapper<Value> {
///     public init(wrappedValue: Value) {
///         self.wrappedValue = wrappedValue
///     }
///
///     public var wrappedValue: Value
/// }
/// ```
///
/// This generates a `MyWrapperMacro` that conforms to `PropertyWrapperMacro` and can be
/// used to apply the property wrapper behavior through macro expansion.
///
/// ## Requirements
///
/// The property wrapper type must:
/// - Be a struct, class, actor, or enum
/// - Have a `wrappedValue` property
/// - Optionally have a `projectedValue` property
///
/// ## Generated Behavior
///
/// The generated macro will:
/// - Create appropriate getters and setters based on the property wrapper's mutability
/// - Handle projected values if present
/// - Support both value and reference types
/// - Pass through initialization arguments
@attached(peer, names: suffixed(Macro))
public macro macrofy() = #externalMacro(module: "MacrofyMacro", type: "MacrofyMacro")
