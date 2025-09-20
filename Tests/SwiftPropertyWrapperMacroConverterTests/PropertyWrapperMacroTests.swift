//
//  PropertyWrapperMacroTests.swift
//  SwiftPropertyWrapperMacroConverter
//
//  Created by Annalise Mariottini on 9/19/25.
//

import Foundation

import XCTest

import SwiftSyntax
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport

@_spi(ExampleMacros)
import SwiftPropertyWrapperMacroConverterMacros

final class PropertyWrapperMacroTests: XCTestCase {
    let testMacros: [String: Macro.Type] = [
        "Example": ExamplePropertyWrapperMacro.self,
        "ExampleSettable": ExampleSettablePropertyWrapperMacro.self,
        "ExampleWithProjected": ExampleWithProjectedPropertyWrapperMacro.self,
        "ExampleWithSettableProjected": ExampleWithSettableProjectedPropertyWrapperMacro.self,
    ]

    func testExamplePropertyWrapperMacro() async throws {
        let original = """
        final class Outer {
            @Example var inner: Inner
        }
        """
        let expected = """
        final class Outer {
            var inner: Inner {
                get {
                    _inner.wrappedValue
                }
            }
        
            private let _inner = Example()
        }
        """

        assertMacroExpansion(original, expandedSource: expected, macros: testMacros)
    }

    func testExamplePropertyWrapperMacro_withArguments() async throws {
        let original = """
        final class Outer {
            @Example("value") var inner: Inner
        }
        """
        let expected = """
        final class Outer {
            var inner: Inner {
                get {
                    _inner.wrappedValue
                }
            }
        
            private let _inner = Example("value")
        }
        """

        assertMacroExpansion(original, expandedSource: expected, macros: testMacros)
    }

    func testExamplePropertyWrapperMacro_withMultipleArguments() async throws {
        let original = """
        final class Outer {
            @Example(0, and: 1, also: 2) var inner: Inner
        }
        """
        let expected = """
        final class Outer {
            var inner: Inner {
                get {
                    _inner.wrappedValue
                }
            }
        
            private let _inner = Example(0, and: 1, also: 2)
        }
        """

        assertMacroExpansion(original, expandedSource: expected, macros: testMacros)
    }

    func testExamplePropertyWrapperMacro_withWrappedValueInitializer() async throws {
        let original = """
        final class Outer {
            @Example var inner: Inner = Inner()
        }
        """
        let expected = """
        final class Outer {
            var inner: Inner {
                get {
                    _inner.wrappedValue
                }
            }
        
            private let _inner = Example(wrappedValue: Inner())
        }
        """

        assertMacroExpansion(original, expandedSource: expected, macros: testMacros)
    }

    func testExamplePropertyWrapperMacro_withWrappedValueInitializer_withAdditionalArguments() async throws {
        let original = """
        final class Outer {
            @Example(more: "value") var inner: Inner = Inner()
        }
        """
        let expected = """
        final class Outer {
            var inner: Inner {
                get {
                    _inner.wrappedValue
                }
            }
        
            private let _inner = Example(wrappedValue: Inner(), more: "value")
        }
        """

        assertMacroExpansion(original, expandedSource: expected, macros: testMacros)
    }

    func testExampleSettablePropertyWrapperMacro() async throws {
        let original = """
        final class Outer {
            @ExampleSettable var inner: Inner
        }
        """
        let expected = """
        final class Outer {
            var inner: Inner {
                get {
                    _inner.wrappedValue
                }
                set {
                    _inner.wrappedValue = newValue
                }
            }
        
            private let _inner = ExampleSettable()
        }
        """

        assertMacroExpansion(original, expandedSource: expected, macros: testMacros)
    }

    func testExampleWithProjectedPropertyWrapperMacro() async throws {
        let original = """
        final class Outer {
            @ExampleWithProjected var inner: Inner
        }
        """
        let expected = """
        final class Outer {
            var inner: Inner {
                get {
                    _inner.wrappedValue
                }
            }
        
            private let _inner = ExampleWithProjected()
        
            var $inner: Int {
                get {
                    _inner.projectedValue
                }
        
            }
        }
        """

        assertMacroExpansion(original, expandedSource: expected, macros: testMacros)
    }

    func testExampleWithProjectedPropertyWrapperMacro_withMatchingAccessLevel() async throws {
        let original = """
        public final class Outer {
            @ExampleWithProjected public var inner: Inner
        }
        """
        let expected = """
        public final class Outer {
            public var inner: Inner {
                get {
                    _inner.wrappedValue
                }
            }
        
            private let _inner = ExampleWithProjected()
        
            public var $inner: Int {
                get {
                    _inner.projectedValue
                }
        
            }
        }
        """

        assertMacroExpansion(original, expandedSource: expected, macros: testMacros)
    }

    func testExampleWithSettableProjectedPropertyWrapperMacro() async throws {
        let original = """
        final class Outer {
            @ExampleWithSettableProjected var inner: Inner
        }
        """
        let expected = """
        final class Outer {
            var inner: Inner {
                get {
                    _inner.wrappedValue
                }
            }
        
            private let _inner = ExampleWithSettableProjected()
        
            var $inner: Int {
                get {
                    _inner.projectedValue
                }
                set {
                    _inner.projectedValue = newValue
                }
            }
        }
        """

        assertMacroExpansion(original, expandedSource: expected, macros: testMacros)
    }
}
