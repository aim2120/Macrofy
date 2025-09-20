//
//  MacrofyPlugin.swift
//  Macrofy
//
//  Created by Annalise Mariottini on 9/19/25.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct ExampleMacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        ExamplePropertyWrapperMacro.self,
        ExampleSettablePropertyWrapperMacro.self,
        ExampleWithProjectedPropertyWrapperMacro.self,
        ExampleWithSettableProjectedPropertyWrapperMacro.self,
        ExampleWithWrappedValuePropertyWrapperMacro.self,
    ]
}
