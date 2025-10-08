import DemoMacro
import DemoPropertyWrapper
import Testing

@Suite
final class DemoIntegrationTests: Sendable {
    @Locked var value = ""

    @Test func accessingLockedValue() {
        let expectedValue = "Hello, World!"
        value = expectedValue
        #expect(value == expectedValue)
        #expect(_value.wrappedValue == expectedValue)
    }
}
