@testable import ClientLibrary
import Combine
import Testing

@Test func lockedValue() async throws {
    let client = Client()
    let expectedValue = "Hello, World!"
    client.lockedValue = expectedValue
    #expect(client.lockedValue == expectedValue)
}
