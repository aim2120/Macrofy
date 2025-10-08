import Combine
import Testing
@testable import ClientLibrary

@Test func lockedValue() async throws {
    let client = Client()
    let expectedValue = "Hello, World!"
    client.lockedValue = expectedValue
    #expect(client.lockedValue == expectedValue)
}
