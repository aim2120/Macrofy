//
//  ExamplePropertyWrapperMacro.swift
//  SwiftPropertyWrapperMacroConverter
//
//  Created by Annalise Mariottini on 9/19/25.
//

import Foundation

@_spi(ExampleMacros)
@attached(peer, names: arbitrary)
@attached(accessor, names: named(get))
public macro Example(
    _ arguments: Any...
) = #externalMacro(module: "SwiftPropertyWrapperMacroConverterMacros", type: "ExamplePropertyWrapperMacro")

@_spi(ExampleMacros)
@attached(peer, names: arbitrary)
@attached(accessor, names: named(get))
public macro ExampleSettable(
    _ arguments: Any...
) = #externalMacro(module: "SwiftPropertyWrapperMacroConverterMacros", type: "ExampleSettablePropertyWrapperMacro")

@_spi(ExampleMacros)
@attached(peer, names: arbitrary)
@attached(accessor, names: named(get))
public macro ExampleWithProjected(
    _ arguments: Any...
) = #externalMacro(module: "SwiftPropertyWrapperMacroConverterMacros", type: "ExampleWithProjectedPropertyWrapperMacro")

@_spi(ExampleMacros)
@attached(peer, names: arbitrary)
@attached(accessor, names: named(get))
public macro ExampleWithSettableProjected(
    _ arguments: Any...
) = #externalMacro(module: "SwiftPropertyWrapperMacroConverterMacros", type: "ExampleWithSettableProjectedPropertyWrapperMacro")

@_spi(ExampleMacros)
@attached(peer, names: arbitrary)
@attached(accessor, names: named(get))
public macro ExampleWithWrappedValue(
    _ arguments: Any...
) = #externalMacro(module: "SwiftPropertyWrapperMacroConverterMacros", type: "ExampleWithWrappedValuePropertyWrapperMacro")
