import Foundation
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct DemoPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        LockedMacro.self,
    ]
}
