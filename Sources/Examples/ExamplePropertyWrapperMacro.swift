//
//  ExamplePropertyWrapperMacro.swift
//  Macrofy
//
//  Created by Annalise Mariottini on 9/19/25.
//

import Foundation

@attached(peer, names: prefixed(_), prefixed(`$`))
@attached(accessor, names: named(get), named(set))
public macro Example(
    _ arguments: Any...
) = #externalMacro(module: "ExampleMacros", type: "ExampleMacro")

@attached(peer, names: prefixed(_), prefixed(`$`))
@attached(accessor, names: named(get), named(set))
public macro ExampleSettable(
    _ arguments: Any...
) = #externalMacro(module: "ExampleMacros", type: "ExampleSettableMacro")

@attached(peer, names: prefixed(_), prefixed(`$`))
@attached(accessor, names: named(get), named(set))
public macro ExampleWithProjected(
    _ arguments: Any...
) = #externalMacro(module: "ExampleMacros", type: "ExampleWithProjectedMacro")

@attached(peer, names: prefixed(_), prefixed(`$`))
@attached(accessor, names: named(get), named(set))
public macro ExampleWithSettableProjected(
    _ arguments: Any...
) = #externalMacro(module: "ExampleMacros", type: "ExampleWithSettableProjectedMacro")

@attached(peer, names: prefixed(_), prefixed(`$`))
@attached(accessor, names: named(get), named(set))
public macro ExampleWithWrappedValue(
    _ arguments: Any...
) = #externalMacro(module: "ExampleMacros", type: "ExampleWithWrappedValueMacro")
