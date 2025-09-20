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
        ExampleMacro.self,
        ExampleSettableMacro.self,
        ExampleWithProjectedMacro.self,
        ExampleWithSettableProjectedMacro.self,
        ExampleWithWrappedValueMacro.self,
    ]
}
