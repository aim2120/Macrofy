//
//  SwiftPropertyWrapperMacroConverterPlugin.swift
//  SwiftPropertyWrapperMacroConverter
//
//  Created by Annalise Mariottini on 9/19/25.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct SwiftPropertyWrapperMacroConverterPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ExamplePropertyWrapperMacro.self,
        ExampleSettablePropertyWrapperMacro.self,
        ExampleWithProjectedPropertyWrapperMacro.self,
        ExampleWithSettableProjectedPropertyWrapperMacro.self,
        ExampleWithWrappedValuePropertyWrapperMacro.self,
    ]
}
