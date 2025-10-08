import DemoMacro
import DemoPropertyWrapper
import Testing

@Suite
final class DemoIntegrationTests: Sendable {
    @Locked var value = ""

    @Test func accessingLockedValue() {
        let expectedValue = "Hello, World!"
        self.value = expectedValue
        #expect(self.value == expectedValue)
        #expect(self._value.wrappedValue == expectedValue)
    }
}
