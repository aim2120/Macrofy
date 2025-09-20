//
//  ExamplePropertyWrapperMacro.swift
//  Macrofy
//
//  Created by Annalise Mariottini on 9/19/25.
//

import Foundation

@attached(peer, names: arbitrary)
@attached(accessor, names: named(get))
public macro Example(
    _ arguments: Any...
) = #externalMacro(module: "ExampleMacros", type: "ExamplePropertyWrapperMacro")

@attached(peer, names: arbitrary)
@attached(accessor, names: named(get))
public macro ExampleSettable(
    _ arguments: Any...
) = #externalMacro(module: "ExampleMacros", type: "ExampleSettablePropertyWrapperMacro")

@attached(peer, names: arbitrary)
@attached(accessor, names: named(get))
public macro ExampleWithProjected(
    _ arguments: Any...
) = #externalMacro(module: "ExampleMacros", type: "ExampleWithProjectedPropertyWrapperMacro")

@attached(peer, names: arbitrary)
@attached(accessor, names: named(get))
public macro ExampleWithSettableProjected(
    _ arguments: Any...
) = #externalMacro(module: "ExampleMacros", type: "ExampleWithSettableProjectedPropertyWrapperMacro")

@attached(peer, names: arbitrary)
@attached(accessor, names: named(get))
public macro ExampleWithWrappedValue(
    _ arguments: Any...
) = #externalMacro(module: "ExampleMacros", type: "ExampleWithWrappedValuePropertyWrapperMacro")
