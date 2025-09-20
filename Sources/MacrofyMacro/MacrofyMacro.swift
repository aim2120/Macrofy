//
//  MacrofyMacro.swift
//  Macrofy
//
//  Created by Annalise Mariottini on 9/20/25.
//

import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct MacrofyMacro: PeerMacro {
    public static func expansion(of _: AttributeSyntax,
                                 providingPeersOf _: some DeclSyntaxProtocol,
                                 in _: some MacroExpansionContext) throws -> [DeclSyntax]
    {
        []
    }
}
