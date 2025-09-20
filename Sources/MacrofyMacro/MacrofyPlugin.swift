//
//  MacrofyPlugin.swift
//  Macrofy
//
//  Created by Annalise Mariottini on 9/20/25.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct MacrofyPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        MacrofyMacro.self,
    ]
}
