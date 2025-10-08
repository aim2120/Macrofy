import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

#if canImport(DemoMacroInternal)
import DemoMacroInternal

let testMacros: [String: Macro.Type] = [
    "Locked": LockedMacro.self,
]

final class DemoTests: XCTestCase {
    func testMacro() throws {
        assertMacroExpansion(
            """
            final class Consumer {
                @Locked var value: String
            }
            """,
            expandedSource: """
            final class Consumer {
                var value: String {
                    get {
                        _value.wrappedValue
                    }
                    set {
                        _value.wrappedValue = newValue
                    }
                }

                private let _value = Locked()
            }
            """,
            macros: testMacros
        )
    }
}
#endif
