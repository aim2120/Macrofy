//
//  MacrofyMacroTests.swift
//  Macrofy
//
//  Created by Annalise Mariottini on 9/20/25.
//

import Foundation

import XCTest

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport

import MacrofyMacro

final class MacrofyMacroTests: XCTestCase {
    let testMacros: [String: Macro.Type] = [
        "macrofy": MacrofyMacro.self,
    ]

    func testMacrofyMacro() async throws {
        let original = """
        @macrofy
        @propertyWrapper
        struct MyPropertyWrapper {
            let wrappedValue: String = "hello"
        }
        """
        let expected = """
        @propertyWrapper
        struct MyPropertyWrapper {
            let wrappedValue: String = "hello"
        }
        """

        assertMacroExpansion(original, expandedSource: expected, macros: testMacros)
    }
}
