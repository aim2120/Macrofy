import Foundation
@preconcurrency import Combine
import Macrofy
import SwiftSyntax
import SwiftSyntaxMacros

@macrofy
@propertyWrapper
public final class Locked<Value: Sendable>: @unchecked Sendable {
    public init(wrappedValue: Value) {
        self._wrappedValue = wrappedValue
    }
    public var wrappedValue: Value {
        get { lock.withLock { _wrappedValue } }
        set { lock.withLock { _wrappedValue = newValue } }
    }
    private var _wrappedValue: Value
    private let lock = NSLock()
}
