//
//  Macrofy.swift
//  Macrofy
//
//  Created by Annalise Mariottini on 9/20/25.
//

import Foundation

@attached(peer, names: arbitrary)
public macro macrofy(
    _ arguments: Any...
) = #externalMacro(module: "MacrofyMacro", type: "MacrofyMacro")
